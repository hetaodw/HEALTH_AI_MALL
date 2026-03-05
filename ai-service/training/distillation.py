"""
蒸馏训练脚本
使用大模型（如GPT-4）对小模型进行蒸馏
"""

import os
import sys
import json
import torch
from transformers import (
    AutoTokenizer, 
    AutoModelForCausalLM,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling
)
from peft import LoraConfig, get_peft_model
from datasets import load_dataset, Dataset
from typing import List, Dict
import logging

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.logger import Logger
from utils.data_processor import DataProcessor
from utils.model_loader import load_config

logger = Logger("distillation", "logs/distillation.log")


class DistillationTrainer:
    """
    蒸馏训练器
    """
    
    def __init__(self, config: Dict):
        self.config = config
        self.model = None
        self.tokenizer = None
        self.teacher_model = None
        self.teacher_tokenizer = None
        
    def load_models(self):
        """
        加载学生模型和教师模型
        """
        model_config = self.config.get('model', {})
        
        logger.info("加载学生模型（小模型）...")
        self.student_tokenizer = AutoTokenizer.from_pretrained(
            model_config.get('local_path'),
            trust_remote_code=True
        )
        
        self.student_model = AutoModelForCausalLM.from_pretrained(
            model_config.get('local_path'),
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        # 配置LoRA
        lora_config = self._get_lora_config()
        self.student_model = get_peft_model(self.student_model, lora_config)
        
        logger.info(f"学生模型加载完成，可训练参数: {self.student_model.num_parameters(only_trainable=True) / 1e6:.2f}M")
        
        # 加载教师模型（大模型API）
        logger.info("教师模型使用API调用（GPT-4）")
        self.teacher_api_key = os.getenv('OPENAI_API_KEY')
        if not self.teacher_api_key:
            logger.warning("未设置OPENAI_API_KEY，将跳过蒸馏步骤")
    
    def _get_lora_config(self) -> LoraConfig:
        """
        获取LoRA配置
        """
        lora_config_dict = self.config.get('training', {}).get('lora', {})
        
        return LoraConfig(
            r=lora_config_dict.get('r', 16),
            lora_alpha=lora_config_dict.get('lora_alpha', 32),
            target_modules=lora_config_dict.get('target_modules', [
                "q_proj", "k_proj", "v_proj", "o_proj",
                "gate_proj", "up_proj", "down_proj"
            ]),
            lora_dropout=lora_config_dict.get('lora_dropout', 0.05),
            bias=lora_config_dict.get('bias', "none"),
            task_type=lora_config_dict.get('task_type', "CAUSAL_LM")
        )
    
    def prepare_dataset(self, data_path: str) -> Dataset:
        """
        准备训练数据集
        
        Args:
            data_path: 数据文件路径
            
        Returns:
            Hugging Face Dataset
        """
        logger.info(f"加载数据集: {data_path}")
        
        dataset = load_dataset("json", data_files=data_path, split="train")
        
        logger.info(f"数据集大小: {len(dataset)}")
        
        return dataset
    
    def tokenize_function(self, examples: Dict) -> Dict:
        """
        Tokenize函数
        
        Args:
            examples: 数据样本
            
        Returns:
            Tokenized数据
        """
        max_length = self.config.get('model', {}).get('max_length', 2048)
        
        # 合并instruction和output
        texts = [
            inst + outp 
            for inst, outp in zip(examples["instruction"], examples["output"])
        ]
        
        return self.student_tokenizer(
            texts,
            truncation=True,
            max_length=max_length,
            padding="max_length"
        )
    
    def get_teacher_outputs(self, prompts: List[str]) -> List[str]:
        """
        使用教师模型生成输出
        
        Args:
            prompts: 提示词列表
            
        Returns:
            教师模型输出列表
        """
        if not self.teacher_api_key:
            logger.warning("教师模型API Key未设置，使用学生模型自蒸馏")
            return None
        
        from openai import OpenAI
        
        client = OpenAI(api_key=self.teacher_api_key)
        
        outputs = []
        
        for prompt in prompts:
            try:
                response = client.chat.completions.create(
                    model="gpt-4",
                    messages=[
                        {"role": "system", "content": "你是一个专业的商品标签标注助手。"},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.7,
                    max_tokens=512
                )
                
                outputs.append(response.choices[0].message.content)
                
            except Exception as e:
                logger.error(f"教师模型推理失败: {e}")
                outputs.append("")
        
        return outputs
    
    def train(self):
        """
        执行训练
        """
        logger.info("开始蒸馏训练...")
        
        # 准备数据集
        data_config = self.config.get('data', {})
        train_file = data_config.get('train_file', 'data/training/training_data.jsonl')
        
        dataset = self.prepare_dataset(train_file)
        
        # Tokenize数据集
        tokenized_dataset = dataset.map(
            self.tokenize_function,
            batched=True,
            remove_columns=dataset.column_names
        )
        
        # 训练参数
        training_args = TrainingArguments(
            output_dir=self.config.get('training', {}).get('output_dir', 'models/qwen2.5-3b-lora'),
            num_train_epochs=self.config.get('training', {}).get('num_train_epochs', 3),
            per_device_train_batch_size=self.config.get('training', {}).get('per_device_train_batch_size', 4),
            gradient_accumulation_steps=self.config.get('training', {}).get('gradient_accumulation_steps', 4),
            learning_rate=self.config.get('training', {}).get('learning_rate', 2e-4),
            warmup_steps=self.config.get('training', {}).get('warmup_steps', 100),
            logging_steps=self.config.get('training', {}).get('logging_steps', 10),
            save_steps=self.config.get('training', {}).get('save_steps', 100),
            fp16=self.config.get('training', {}).get('fp16', True),
            gradient_checkpointing=self.config.get('training', {}).get('gradient_checkpointing', True),
            logging_dir=self.config.get('training', {}).get('logging_dir', 'logs'),
            save_total_limit=self.config.get('training', {}).get('save_total_limit', 3),
            ddp_find_unused_parameters=self.config.get('training', {}).get('ddp_find_unused_parameters', False)
        )
        
        # 数据整理器
        data_collator = DataCollatorForLanguageModeling(
            tokenizer=self.student_tokenizer,
            mlm=False
        )
        
        # 创建Trainer
        trainer = Trainer(
            model=self.student_model,
            args=training_args,
            train_dataset=tokenized_dataset,
            data_collator=data_collator
        )
        
        # 开始训练
        logger.info("开始训练...")
        trainer.train()
        
        # 保存模型
        logger.info("保存模型...")
        output_dir = self.config.get('training', {}).get('output_dir', 'models/qwen2.5-3b-lora')
        trainer.save_model(output_dir)
        self.student_tokenizer.save_pretrained(output_dir)
        
        logger.info(f"模型已保存到: {output_dir}")
        logger.info("训练完成！")


def main():
    """
    主函数
    """
    logger.info("=" * 80)
    logger.info("Qwen2.5-3B 蒸馏训练")
    logger.info("=" * 80)
    
    # 加载配置
    config = load_config()
    
    # 创建训练器
    trainer = DistillationTrainer(config)
    
    try:
        # 加载模型
        trainer.load_models()
        
        # 训练
        trainer.train()
        
    except Exception as e:
        logger.error(f"训练失败: {e}")
        raise


if __name__ == "__main__":
    main()
