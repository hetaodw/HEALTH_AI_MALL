"""
数据处理工具
用于处理商品数据和标签数据
"""

import json
import pandas as pd
from typing import List, Dict, Any
import logging
import re

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DataProcessor:
    """
    数据处理器类
    """
    
    def __init__(self):
        self.tag_types = {
            'function': '功能标签',
            'audience': '适用人群',
            'ingredient': '成分标签',
            'scene': '场景标签',
            'brand': '品牌标签',
            'price': '价格区间'
        }
    
    def process_product_data(self, products: List[Dict]) -> List[Dict]:
        """
        处理商品数据
        
        Args:
            products: 商品列表
            
        Returns:
            处理后的商品列表
        """
        processed = []
        
        for product in products:
            processed_product = {
                'id': product.get('id'),
                'title': self._clean_text(product.get('title', '')),
                'description': self._clean_text(product.get('description', '')),
                'description_content': self._clean_text(product.get('description_content', '')),
                'category': product.get('category'),
                'price': float(product.get('price', 0)),
                'cover_url': product.get('cover_url', '')
            }
            
            processed.append(processed_product)
        
        logger.info(f"处理了 {len(processed)} 个商品")
        return processed
    
    def prepare_training_data(self, products: List[Dict], tags: List[Dict]) -> List[Dict]:
        """
        准备训练数据
        
        Args:
            products: 商品列表
            tags: 标签列表
            
        Returns:
            训练数据列表
        """
        training_data = []
        
        # 创建商品ID到标签的映射
        product_tags_map = {}
        for tag in tags:
            product_id = tag.get('product_id')
            if product_id not in product_tags_map:
                product_tags_map[product_id] = {
                    'function_tags': [],
                    'audience_tags': [],
                    'ingredient_tags': [],
                    'scene_tags': [],
                    'brand_tags': [],
                    'price_tags': []
                }
            
            tag_type = tag.get('tag_type')
            tag_name = tag.get('tag_name')
            confidence = tag.get('confidence', 1.0)
            
            if confidence >= 0.7:  # 只使用高置信度标签
                if tag_type == 'function':
                    product_tags_map[product_id]['function_tags'].append(tag_name)
                elif tag_type == 'audience':
                    product_tags_map[product_id]['audience_tags'].append(tag_name)
                elif tag_type == 'ingredient':
                    product_tags_map[product_id]['ingredient_tags'].append(tag_name)
                elif tag_type == 'scene':
                    product_tags_map[product_id]['scene_tags'].append(tag_name)
                elif tag_type == 'brand':
                    product_tags_map[product_id]['brand_tags'].append(tag_name)
                elif tag_type == 'price':
                    product_tags_map[product_id]['price_tags'].append(tag_name)
        
        # 合并商品和标签
        for product in products:
            product_id = product.get('id')
            if product_id in product_tags_map:
                training_item = {
                    'product': product,
                    'tags': product_tags_map[product_id]
                }
                training_data.append(training_item)
        
        logger.info(f"准备了 {len(training_data)} 条训练数据")
        return training_data
    
    def create_training_prompt(self, product: Dict, tags: Dict) -> str:
        """
        创建训练提示词
        
        Args:
            product: 商品数据
            tags: 标签数据
            
        Returns:
            提示词字符串
        """
        prompt = f"""请为以下商品提取标签，返回JSON格式：

标题：{product.get('title', '')}
描述：{product.get('description', '')}
详细描述：{product.get('description_content', '')}
分类：{product.get('category', '')}
价格：{product.get('price', 0)}

标签类型：
1. 功能标签（如：增强免疫、补充维生素、改善睡眠、美容养颜、减肥塑形）
2. 适用人群（如：成人、儿童、老人、孕妇）
3. 成分标签（如：维生素C、蛋白质、胶原蛋白、益生菌）
4. 场景标签（如：日常保健、运动后、睡前）
5. 品牌标签（如：汤臣倍健、Swisse、Move Free）
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
        
        return prompt
    
    def format_training_data(self, training_data: List[Dict]) -> List[Dict]:
        """
        格式化训练数据为模型输入格式
        
        Args:
            training_data: 训练数据列表
            
        Returns:
            格式化后的训练数据
        """
        formatted = []
        
        for item in training_data:
            product = item['product']
            tags = item['tags']
            
            prompt = self.create_training_prompt(product, tags)
            response = json.dumps(tags, ensure_ascii=False)
            
            formatted.append({
                'instruction': prompt,
                'output': response
            })
        
        return formatted
    
    def save_training_data(self, training_data: List[Dict], output_path: str):
        """
        保存训练数据为JSONL格式
        
        Args:
            training_data: 训练数据
            output_path: 输出路径
        """
        with open(output_path, 'w', encoding='utf-8') as f:
            for item in training_data:
                f.write(json.dumps(item, ensure_ascii=False) + '\n')
        
        logger.info(f"训练数据已保存到: {output_path}")
    
    def load_training_data(self, input_path: str) -> List[Dict]:
        """
        加载训练数据
        
        Args:
            input_path: 输入路径
            
        Returns:
            训练数据列表
        """
        training_data = []
        
        with open(input_path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip():
                    training_data.append(json.loads(line))
        
        logger.info(f"从 {input_path} 加载了 {len(training_data)} 条训练数据")
        return training_data
    
    def _clean_text(self, text: str) -> str:
        """
        清理文本
        
        Args:
            text: 原始文本
            
        Returns:
            清理后的文本
        """
        if not text:
            return ''
        
        # 移除多余空格
        text = re.sub(r'\s+', ' ', text)
        
        # 移除特殊字符（保留中文、英文、数字、常用标点）
        text = re.sub(r'[^\u4e00-\u9fa5a-zA-Z0-9，。、！？；：""''（）【】\s]', '', text)
        
        return text.strip()
    
    def extract_brand_from_title(self, title: str) -> str:
        """
        从标题中提取品牌
        
        Args:
            title: 商品标题
            
        Returns:
            品牌名称
        """
        # 常见品牌列表
        common_brands = [
            '汤臣倍健', 'Swisse', 'Move Free', 'GNC', 'Blackmores',
            'Nature Made', 'Centrum', 'Osteo Bi-Flex', 'Schiff',
            '钙尔奇', '善存', '黄金搭档', '纽崔莱', '安利'
        ]
        
        for brand in common_brands:
            if brand in title:
                return brand
        
        return ''
    
    def get_price_range(self, price: float) -> str:
        """
        获取价格区间标签
        
        Args:
            price: 价格
            
        Returns:
            价格区间标签
        """
        if price < 50:
            return '0-50元'
        elif price < 100:
            return '50-100元'
        elif price < 300:
            return '100-300元'
        else:
            return '300元以上'


if __name__ == "__main__":
    # 测试数据处理
    processor = DataProcessor()
    
    # 测试商品数据
    test_product = {
        'id': 1,
        'title': '汤臣倍健维生素C片 100片',
        'description': '增强免疫力，抗氧化',
        'description_content': '这款天然维C片采用优质原料，每片含有500mg维生素C',
        'category': 'HEALTH_PRODUCTS',
        'price': 59.9,
        'cover_url': 'http://example.com/image.jpg'
    }
    
    # 测试标签数据
    test_tags = [
        {
            'product_id': 1,
            'tag_type': 'function',
            'tag_name': '增强免疫',
            'confidence': 0.95
        },
        {
            'product_id': 1,
            'tag_type': 'ingredient',
            'tag_name': '维生素C',
            'confidence': 0.98
        },
        {
            'product_id': 1,
            'tag_type': 'brand',
            'tag_name': '汤臣倍健',
            'confidence': 0.99
        },
        {
            'product_id': 1,
            'tag_type': 'price',
            'tag_name': '50-100元',
            'confidence': 1.0
        }
    ]
    
    # 处理数据
    processed_product = processor.process_product_data([test_product])[0]
    training_data = processor.prepare_training_data([processed_product], test_tags)
    formatted_data = processor.format_training_data(training_data)
    
    # 保存测试数据
    processor.save_training_data(formatted_data, 'data/training/test_training_data.jsonl')
    
    # 打印提示词
    print("=" * 80)
    print("训练提示词示例：")
    print("=" * 80)
    print(formatted_data[0]['instruction'])
    print("\n")
    print("=" * 80)
    print("期望输出：")
    print("=" * 80)
    print(formatted_data[0]['output'])
