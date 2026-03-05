"""
模型下载脚本
用于下载Qwen3.5-2B基座模型
"""

import os

# 解决OpenMP冲突问题 - 必须在导入torch之前设置
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

from huggingface_hub import snapshot_download
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
from tqdm import tqdm
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MODEL_NAME = "Qwen/Qwen2.5-3B-Instruct"
MODEL_DIR = "models/qwen2.5-3b-instruct"
USE_4BIT = True  # 是否使用4bit量化下载

def download_model():
    """
    下载Qwen2.5-3B-Instruct模型
    """
    logger.info(f"开始下载模型: {MODEL_NAME}")
    logger.info(f"保存路径: {MODEL_DIR}")
    logger.info(f"4bit量化: {USE_4BIT}")
    
    try:
        if USE_4BIT:
            logger.info("使用4bit量化下载，节省磁盘空间")
            download_quantized_model()
        else:
            logger.info("下载完整模型")
            download_full_model()
        
        logger.info("模型下载完成！")
        logger.info(f"模型路径: {os.path.abspath(MODEL_DIR)}")
        
        # 验证模型
        verify_model()
        
    except Exception as e:
        logger.error(f"模型下载失败: {e}")
        raise

def download_full_model():
    """
    下载完整模型
    """
    snapshot_download(
        repo_id=MODEL_NAME,
        local_dir=MODEL_DIR,
        local_dir_use_symlinks=False,
        resume_download=True,
        tqdm_class=tqdm
    )

def download_quantized_model():
    """
    下载并量化模型为4bit
    """
    from transformers import BitsAndBytesConfig, AutoModelForCausalLM
    
    logger.info("加载tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(
        MODEL_NAME,
        trust_remote_code=True
    )
    
    logger.info("加载模型并应用4bit量化...")
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_NAME,
        quantization_config=BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_use_double_quant=True,
            bnb_4bit_quant_type="nf4"
        ),
        trust_remote_code=True,
        device_map="auto"
    )
    
    logger.info("保存量化模型...")
    model.save_pretrained(MODEL_DIR)
    tokenizer.save_pretrained(MODEL_DIR)
    
    logger.info("4bit量化模型保存完成")

def verify_model():
    """
    验证下载的模型是否可用
    """
    logger.info("验证模型...")
    
    try:
        from transformers import AutoTokenizer, AutoModelForCausalLM
        
        logger.info("加载tokenizer...")
        tokenizer = AutoTokenizer.from_pretrained(
            MODEL_DIR,
            trust_remote_code=True
        )
        
        logger.info("加载模型...")
        model = AutoModelForCausalLM.from_pretrained(
            MODEL_DIR,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        logger.info("测试推理...")
        test_prompt = "你好，请介绍一下自己。"
        inputs = tokenizer(test_prompt, return_tensors="pt").to(model.device)
        
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=50,
                temperature=0.7
            )
        
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        logger.info(f"测试输出: {response}")
        
        logger.info("模型验证成功！")
        
    except Exception as e:
        logger.error(f"模型验证失败: {e}")
        raise

def print_model_info():
    """
    打印模型信息
    """
    logger.info("=" * 60)
    logger.info("模型下载配置")
    logger.info("=" * 60)
    logger.info(f"模型名称: {MODEL_NAME}")
    logger.info(f"保存路径: {MODEL_DIR}")
    logger.info(f"4bit量化: {USE_4BIT}")
    logger.info(f"磁盘空间需求: {'~2GB (4bit)' if USE_4BIT else '~5GB (full)'}")
    logger.info("=" * 60)

if __name__ == "__main__":
    print_model_info()
    download_model()
