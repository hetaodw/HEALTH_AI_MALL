"""
模型加载工具
用于加载和管理AI模型
"""

import os

# 解决OpenMP冲突问题 - 必须在导入torch之前设置
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
from typing import Optional, Dict, Any
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ModelLoader:
    """
    模型加载器类
    """
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.model = None
        self.tokenizer = None
        self.device = None
        
    def load_model(self, model_path: Optional[str] = None) -> tuple:
        """
        加载模型和tokenizer
        
        Args:
            model_path: 模型路径，如果为None则使用配置中的路径
            
        Returns:
            (model, tokenizer) 元组
        """
        if model_path is None:
            model_path = self.config.get('model', {}).get('local_path')
        
        logger.info(f"加载模型: {model_path}")
        
        try:
            # 加载tokenizer
            logger.info("加载tokenizer...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                model_path,
                trust_remote_code=True
            )
            
            # 配置量化
            quantization_config = self._get_quantization_config()
            
            # 加载模型
            logger.info("加载模型...")
            self.model = AutoModelForCausalLM.from_pretrained(
                model_path,
                quantization_config=quantization_config,
                torch_dtype=self._get_torch_dtype(),
                device_map=self._get_device_map(),
                trust_remote_code=True
            )
            
            self.model.eval()
            
            logger.info("模型加载完成")
            logger.info(f"模型设备: {next(self.model.parameters()).device}")
            logger.info(f"模型参数量: {self.model.num_parameters() / 1e9:.2f}B")
            
            return self.model, self.tokenizer
            
        except Exception as e:
            logger.error(f"模型加载失败: {e}")
            raise
    
    def _get_quantization_config(self) -> Optional[BitsAndBytesConfig]:
        """
        获取量化配置
        """
        quant_config = self.config.get('model', {}).get('quantization', {})
        
        if not quant_config.get('enabled', False):
            logger.info("未启用量化")
            return None
        
        logger.info(f"启用{quant_config.get('bits', 4)}bit量化")
        
        return BitsAndBytesConfig(
            load_in_4bit=quant_config.get('bits', 4) == 4,
            load_in_8bit=quant_config.get('bits', 4) == 8,
            bnb_4bit_compute_dtype=self._get_torch_dtype(),
            bnb_4bit_use_double_quant=quant_config.get('use_double_quant', True),
            bnb_4bit_quant_type=quant_config.get('quant_type', 'nf4')
        )
    
    def _get_torch_dtype(self):
        """
        获取torch数据类型
        """
        dtype_str = self.config.get('model', {}).get('torch_dtype', 'float16')
        
        dtype_map = {
            'float16': torch.float16,
            'float32': torch.float32,
            'bfloat16': torch.bfloat16
        }
        
        return dtype_map.get(dtype_str, torch.float16)
    
    def _get_device_map(self):
        """
        获取设备映射
        """
        device = self.config.get('model', {}).get('device', 'auto')
        
        if device == 'auto':
            return 'auto'
        elif device == 'cuda':
            return 'cuda'
        elif device == 'cpu':
            return 'cpu'
        else:
            return 'auto'
    
    def unload_model(self):
        """
        卸载模型，释放内存
        """
        if self.model is not None:
            logger.info("卸载模型...")
            del self.model
            self.model = None
        
        if self.tokenizer is not None:
            del self.tokenizer
            self.tokenizer = None
        
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        
        logger.info("模型已卸载，内存已释放")


def load_config(config_path: str = "config/model_config.yaml") -> Dict[str, Any]:
    """
    加载配置文件
    
    Args:
        config_path: 配置文件路径
        
    Returns:
        配置字典
    """
    import yaml
    
    if not os.path.exists(config_path):
        logger.warning(f"配置文件不存在: {config_path}，使用默认配置")
        return {}
    
    with open(config_path, 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    
    logger.info(f"配置文件加载成功: {config_path}")
    return config


if __name__ == "__main__":
    # 测试模型加载
    config = load_config()
    loader = ModelLoader(config)
    
    try:
        model, tokenizer = loader.load_model()
        logger.info("模型加载测试成功")
        
        # 测试推理
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
        
    finally:
        loader.unload_model()
