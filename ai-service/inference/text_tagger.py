"""
文本标签提取脚本
使用Qwen2.5-3B模型提取商品标签
"""

import os

# 解决OpenMP冲突问题 - 必须在导入torch之前设置
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import sys
import json
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from typing import Dict, List

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.logger import Logger
from utils.model_loader import load_config

logger = Logger("text_tagger", "logs/text_tagger.log")


class TextTagger:
    """
    文本标签提取器
    """
    
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.model = None
        self.tokenizer = None
        self.device = None
        
        self.load_model()
    
    def load_model(self):
        """
        加载模型
        """
        logger.info(f"加载模型: {self.model_path}")
        
        try:
            # 加载tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                self.model_path,
                trust_remote_code=True
            )
            
            # 加载模型
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_path,
                torch_dtype=torch.float16,
                device_map="auto",
                trust_remote_code=True
            )
            
            self.model.eval()
            self.device = next(self.model.parameters()).device
            
            logger.info(f"模型加载成功，设备: {self.device}")
            
        except Exception as e:
            logger.error(f"模型加载失败: {e}")
            raise
    
    def extract_tags(self, product: Dict) -> Dict:
        """
        提取商品标签
        
        Args:
            product: 商品数据字典
            
        Returns:
            标签字典
        """
        prompt = self._build_prompt(product)
        
        try:
            # Tokenize输入
            inputs = self.tokenizer(prompt, return_tensors="pt").to(self.device)
            
            # 生成输出
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=512,
                    temperature=0.7,
                    do_sample=True,
                    top_p=0.9,
                    top_k=50,
                    repetition_penalty=1.1
                )
            
            # 解码输出
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # 解析JSON响应
            tags = self._parse_response(response)
            
            return tags
            
        except Exception as e:
            logger.error(f"标签提取失败: {e}")
            return self._empty_tags()
    
    def _build_prompt(self, product: Dict) -> str:
        """
        构建提示词
        
        Args:
            product: 商品数据
            
        Returns:
            提示词字符串
        """
        return f"""请为以下商品提取标签，返回JSON格式：

标题：{product.get('title', '')}
描述：{product.get('description', '')}
详细描述：{product.get('description_content', '')}
分类：{product.get('category', '')}
价格：{product.get('price', 0)}

标签类型：
1. 功能标签（如：增强免疫、补充维生素、改善睡眠、美容养颜、减肥塑形、运动健身）
2. 适用人群（如：成人、儿童、老人、孕妇、婴幼儿）
3. 成分标签（如：维生素C、蛋白质、胶原蛋白、益生菌、钙、铁）
4. 场景标签（如：日常保健、运动后、睡前、餐后）
5. 品牌标签（如：汤臣倍健、Swisse、Move Free、GNC、Blackmores）
6. 价格区间（如：0-50元、50-100元、100-300元、300元以上）

返回格式：
{{
  "function_tags": ["标签1", "标签2"],
  "audience_tags": ["标签1", "标签2"],
  "ingredient_tags": ["标签1", "标签2"],
  "scene_tags": ["标签1", "标签2"],
  "brand_tags": ["标签1", "标签2"],
  "price_tags": ["标签1", "标签2"]
}}

只返回JSON，不要其他内容。"""
    
    def _parse_response(self, response: str) -> Dict:
        """
        解析模型响应
        
        Args:
            response: 模型输出字符串
            
        Returns:
            解析后的标签字典
        """
        try:
            # 查找JSON部分
            json_start = response.find('{')
            json_end = response.rfind('}') + 1
            
            if json_start == -1 or json_end == 0:
                logger.warning(f"未找到JSON格式响应: {response}")
                return self._empty_tags()
            
            json_str = response[json_start:json_end]
            tags = json.loads(json_str)
            
            # 验证标签格式
            required_keys = [
                'function_tags', 'audience_tags', 'ingredient_tags',
                'scene_tags', 'brand_tags', 'price_tags'
            ]
            
            for key in required_keys:
                if key not in tags:
                    tags[key] = []
            
            return tags
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON解析失败: {e}")
            logger.debug(f"原始响应: {response}")
            return self._empty_tags()
        except Exception as e:
            logger.error(f"响应解析失败: {e}")
            return self._empty_tags()
    
    def _empty_tags(self) -> Dict:
        """
        返回空标签字典
        """
        return {
            'function_tags': [],
            'audience_tags': [],
            'ingredient_tags': [],
            'scene_tags': [],
            'brand_tags': [],
            'price_tags': []
        }
    
    def batch_extract_tags(self, products: List[Dict]) -> List[Dict]:
        """
        批量提取标签
        
        Args:
            products: 商品列表
            
        Returns:
            标签列表
        """
        results = []
        
        for i, product in enumerate(products):
            logger.info(f"处理商品 {i+1}/{len(products)}: {product.get('title', '')}")
            
            tags = self.extract_tags(product)
            results.append(tags)
        
        logger.info(f"批量标签提取完成，共 {len(results)} 个商品")
        return results


def main():
    """
    主函数
    """
    logger.info("=" * 80)
    logger.info("Qwen2.5-3B 文本标签提取")
    logger.info("=" * 80)
    
    # 加载配置
    config = load_config()
    model_path = config.get('model', {}).get('local_path', 'models/qwen2.5-3b-instruct')
    
    # 创建标签提取器
    tagger = TextTagger(model_path)
    
    # 测试商品
    test_products = [
        {
            'id': 1,
            'title': '汤臣倍健维生素C片 100片',
            'description': '增强免疫力，抗氧化，促进胶原蛋白合成',
            'description_content': '这款天然维C片采用优质原料，每片含有500mg维生素C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。适合日常保健，增强身体抵抗力。',
            'category': 'HEALTH_PRODUCTS',
            'price': 59.9
        },
        {
            'id': 2,
            'title': 'Swisse 钙+维生素D片 150片',
            'description': '补钙强骨，促进钙吸收',
            'description_content': 'Swisse钙+维生素D片，每片含钙200mg，维生素D3 500IU，科学配比，促进钙吸收，增强骨密度，适合中老年人及缺钙人群。',
            'category': 'HEALTH_PRODUCTS',
            'price': 89.0
        },
        {
            'id': 3,
            'title': 'Move Free 氨糖软骨素 80片',
            'description': '关节养护，缓解关节疼痛',
            'description_content': 'Move Free氨糖软骨素，含有氨糖、软骨素、MSM等多种关节营养成分，帮助修复关节软骨，缓解关节疼痛，改善关节灵活性，适合运动人群及中老年人。',
            'category': 'MEDICAL_DEVICES',
            'price': 159.0
        }
    ]
    
    # 提取标签
    results = tagger.batch_extract_tags(test_products)
    
    # 打印结果
    for product, tags in zip(test_products, results):
        print("\n" + "=" * 80)
        print(f"商品: {product['title']}")
        print("=" * 80)
        print(json.dumps(tags, ensure_ascii=False, indent=2))
        print("\n")
    
    # 保存结果
    output_path = "data/processed/test_tags.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump({
            'products': test_products,
            'tags': results
        }, f, ensure_ascii=False, indent=2)
    
    logger.info(f"结果已保存到: {output_path}")


if __name__ == "__main__":
    main()
