import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
import json
import logging
import re
from typing import Dict, List, Optional
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from utils.logger import Logger
from utils.model_loader import load_config

logger = Logger("ai_service", "logs/ai_service.log")

config = load_config()

# 🔧 硬编码模型路径
base_model_path = r'D:\26bs\ai-service\models\Qwen3___5-2B'
lora_adapter_path = r'D:\26bs\ai-service\models\qwen3.5-2b-lora-finetuned'  # ✅ 硬编码 LoRA 路径

model = None
tokenizer = None
device = None


class GenerateTagsRequest(BaseModel):
    prompt: str = Field(..., description="生成标签的提示词")


class GenerateTagsResponse(BaseModel):
    tags: List[str] = Field(..., description="生成的标签列表")


class HealthResponse(BaseModel):
    status: str = Field(..., description="服务状态")
    model_loaded: bool = Field(..., description="模型是否已加载")
    device: Optional[str] = Field(None, description="设备信息")


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model, tokenizer, device
    
    logger.info("=" * 80)
    logger.info("AI服务启动中...")
    logger.info("=" * 80)
    
    try:
        # 路径校验
        if not os.path.exists(base_model_path):
            raise FileNotFoundError(f"基础模型路径不存在: {base_model_path}")
        if lora_adapter_path and not os.path.exists(lora_adapter_path):
            raise FileNotFoundError(f"LoRA适配器路径不存在: {lora_adapter_path}")
        
        if lora_adapter_path:
            logger.info(f"加载基础模型: {base_model_path}")
            logger.info(f"加载LoRA适配器: {lora_adapter_path}")
        else:
            logger.info(f"加载模型: {base_model_path}")
        
        tokenizer = AutoTokenizer.from_pretrained(
            base_model_path,
            trust_remote_code=True
        )
        
        base_model = AutoModelForCausalLM.from_pretrained(
            base_model_path,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        if lora_adapter_path:
            logger.info("应用LoRA适配器...")
            model = PeftModel.from_pretrained(
                base_model,
                lora_adapter_path,
                torch_dtype=torch.float16
            )
        else:
            model = base_model
        
        model.eval()
        device = next(model.parameters()).device
        
        logger.info(f"模型加载成功，设备: {device}")
        
    except Exception as e:
        logger.error(f"模型加载失败: {e}", exc_info=True)
        raise
    
    yield
    
    logger.info("AI服务关闭中...")


app = FastAPI(
    title="AI Tag Generation Service",
    description="使用Qwen3.5-2B模型为商品生成标签",
    version="1.0.0",
    lifespan=lifespan
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"未处理的异常: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"error": "内部服务器错误", "detail": str(exc)}
    )


@app.get("/health", response_model=HealthResponse)
async def health_check():
    global model, tokenizer, device
    
    return HealthResponse(
        status="healthy" if model is not None else "unhealthy",
        model_loaded=model is not None,
        device=str(device) if device else None
    )


@app.post("/api/generate-tags", response_model=GenerateTagsResponse)
async def generate_tags(request: GenerateTagsRequest):
    global model, tokenizer, device
    
    if model is None or tokenizer is None:
        raise HTTPException(status_code=503, detail="模型未加载")
    
    try:
        prompt_text = request.prompt
        logger.info(f"收到请求 - prompt长度: {len(prompt_text)}")
        
        messages = [{"role": "user", "content": prompt_text}]
        prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True, enable_thinking=False)
        logger.info(f"格式化后的prompt: {prompt[:200]}...")
        
        inputs = tokenizer(prompt, return_tensors="pt").to(device)
        
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=512,
                temperature=0.7,
                do_sample=True,
                top_p=0.9,
                top_k=50,
                repetition_penalty=1.1
            )
        
        # ✅ 核心修复：截取模型新生成的 token，避开输入 prompt 的干扰
        input_length = inputs.input_ids.shape[1]
        generated_ids = outputs[0][input_length:]
        
        response = tokenizer.decode(generated_ids, skip_special_tokens=True)
        logger.info(f"模型纯净输出: {response}")
        
        tags = parse_tags(response)
        
        return GenerateTagsResponse(tags=tags)
        
    except Exception as e:
        logger.error(f"标签生成失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"标签生成失败: {str(e)}")


def parse_tags(response: str) -> List[str]:
    try:
        cleaned = re.sub(r'<think>.*?</think>', '', response, flags=re.DOTALL).strip()
        
        json_match = re.search(r'\[.*?\]', cleaned, re.DOTALL)
        
        if not json_match:
            logger.warning(f"未找到JSON数组格式响应: {response}")
            return []
        
        json_str = json_match.group(0)
        logger.info(f"提取的JSON: {json_str}")
        
        try:
            tags = json.loads(json_str)
        except json.JSONDecodeError:
            logger.info("尝试解析非标准JSON格式...")
            tags = parse_non_standard_json(json_str)
        
        if isinstance(tags, list):
            return list(set(str(tag).strip() for tag in tags if tag))
        
        return []
        
    except Exception as e:
        logger.error(f"响应解析失败: {e}")
        return []


def parse_non_standard_json(json_str: str) -> List[str]:
    try:
        content = json_str.strip()
        if content.startswith('[') and content.endswith(']'):
            content = content[1:-1].strip()
        
        if not content:
            return []
        
        items = [item.strip() for item in content.split(',')]
        return [item for item in items if item]
    except Exception as e:
        logger.error(f"非标准JSON解析失败: {e}")
        return []


if __name__ == "__main__":
    # 恢复正常的配置读取
    host = config.get('server', {}).get('host', '0.0.0.0')
    port = config.get('server', {}).get('port', 5001)
    
    logger.info(f"启动服务: {host}:{port}")
    
    uvicorn.run(
        "app:app",  # 确保当前文件名为 app.py
        host=host,
        port=port,
        reload=False,
        log_level="info"
    )