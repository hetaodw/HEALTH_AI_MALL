import os
import json
import torch
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    TrainingArguments,
    Trainer,
    DataCollatorForSeq2Seq
)
from peft import (
    LoraConfig,
    get_peft_model,
    TaskType
)
from datasets import load_dataset
from typing import Dict

MODEL_PATH = r"D:\26bs\ai-service\models\Qwen3___5-2B"
DATA_PATH = r"D:\26bs\ai-service\data\training\training_data_qwen.jsonl"
OUTPUT_DIR = r"D:\26bs\ai-service\models\qwen3.5-2b-lora-finetuned"

def load_training_data(data_path):
    with open(data_path, 'r', encoding='utf-8') as f:
        data = [json.loads(line) for line in f]
    return data

def format_example(example):
    instruction = example['instruction']
    output = example['output']
    
    text = f"<|im_start|>user\n{instruction}<|im_end|>\n<|im_start|>assistant\n{output}<|im_end|>"
    return text

def preprocess_function(examples, tokenizer, max_length=512):
    instructions = examples['instruction']
    outputs = examples['output']
    
    texts = []
    for instruction, output in zip(instructions, outputs):
        text = f"<|im_start|>user\n{instruction}<|im_end|>\n<|im_start|>assistant\n{output}<|im_end|>"
        texts.append(text)
    
    model_inputs = tokenizer(
        texts,
        max_length=max_length,
        padding=False,
        truncation=True,
        return_tensors=None
    )
    
    model_inputs["labels"] = model_inputs["input_ids"].copy()
    
    return model_inputs

def main():
    print("加载训练数据...")
    train_data = load_training_data(DATA_PATH)
    print(f"训练数据数量: {len(train_data)}")
    
    print("加载模型和分词器...")
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, trust_remote_code=True)
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_PATH,
        trust_remote_code=True,
        dtype=torch.bfloat16,
        device_map="auto"
    )
    
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    
    print("配置LoRA...")
    lora_config = LoraConfig(
        task_type=TaskType.CAUSAL_LM,
        inference_mode=False,
        r=16,
        lora_alpha=32,
        lora_dropout=0.05,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
        bias="none"
    )
    
    model = get_peft_model(model, lora_config)
    model.print_trainable_parameters()
    
    print("准备训练数据集...")
    from datasets import Dataset
    
    train_dataset = Dataset.from_list(train_data)
    tokenized_dataset = train_dataset.map(
        lambda x: preprocess_function(x, tokenizer),
        batched=True,
        remove_columns=train_dataset.column_names
    )
    
    print("配置训练参数...")
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        num_train_epochs=3,
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=100,
        logging_steps=10,
        save_steps=100,
        learning_rate=2e-4,
        fp16=False,
        bf16=True,
        max_grad_norm=0.3,
        max_steps=-1,
        weight_decay=0.01,
        optim="paged_adamw_32bit",
        lr_scheduler_type="cosine",
        save_total_limit=3,
        logging_dir=os.path.join(OUTPUT_DIR, "logs"),
        report_to="tensorboard",
        remove_unused_columns=False
    )
    
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        data_collator=DataCollatorForSeq2Seq(
            tokenizer=tokenizer,
            model=model,
            padding=True
        )
    )
    
    print("开始训练...")
    trainer.train()
    
    print("保存模型...")
    model.save_pretrained(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)
    
    print(f"训练完成！模型已保存到: {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
