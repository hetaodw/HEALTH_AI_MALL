"""
数据准备脚本
从数据库提取商品数据并准备训练数据
"""

import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_processor import DataProcessor
from utils.logger import Logger
import json
import pymysql
from typing import List, Dict

logger = Logger("prepare_data", "logs/prepare_data.log")


def load_products_from_db() -> List[Dict]:
    """
    从数据库加载商品数据
    
    Returns:
        商品列表
    """
    try:
        connection = pymysql.connect(
            host='localhost',
            port=4000,
            user='root',
            password='123456',
            database='health_mall_system',
            charset='utf8mb4'
        )
        
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # 查询商品数据
        sql = """
        SELECT 
            id, title, description, description_content, 
            category, price, cover_url
        FROM products
        WHERE status = 'ON_SALE'
        ORDER BY id
        LIMIT 1000
        """
        
        cursor.execute(sql)
        products = cursor.fetchall()
        
        cursor.close()
        connection.close()
        
        logger.info(f"从数据库加载了 {len(products)} 个商品")
        return products
        
    except Exception as e:
        logger.error(f"从数据库加载商品失败: {e}")
        return []


def load_tags_from_db() -> List[Dict]:
    """
    从数据库加载标签数据
    
    Returns:
        标签列表
    """
    try:
        connection = pymysql.connect(
            host='localhost',
            port=4000,
            user='root',
            password='123456',
            database='health_mall_system',
            charset='utf8mb4'
        )
        
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # 查询标签数据
        sql = """
        SELECT 
            ptr.product_id,
            pt.tag_name,
            pt.tag_type,
            ptr.confidence
        FROM product_tag_relations ptr
        JOIN product_tags pt ON ptr.tag_id = pt.id
        WHERE ptr.confidence >= 0.7
        ORDER BY ptr.product_id
        """
        
        cursor.execute(sql)
        tags = cursor.fetchall()
        
        cursor.close()
        connection.close()
        
        logger.info(f"从数据库加载了 {len(tags)} 条标签")
        return tags
        
    except Exception as e:
        logger.error(f"从数据库加载标签失败: {e}")
        return []


def prepare_training_data():
    """
    准备训练数据
    """
    logger.info("开始准备训练数据...")
    
    # 加载数据
    products = load_products_from_db()
    tags = load_tags_from_db()
    
    if not products:
        logger.error("没有商品数据，请先添加商品")
        return
    
    # 处理数据
    processor = DataProcessor()
    processed_products = processor.process_product_data(products)
    
    # 准备训练数据
    if tags:
        training_data = processor.prepare_training_data(processed_products, tags)
        formatted_data = processor.format_training_data(training_data)
        
        # 保存训练数据
        output_path = "data/training/training_data.jsonl"
        processor.save_training_data(formatted_data, output_path)
        
        logger.info(f"训练数据准备完成，共 {len(formatted_data)} 条")
    else:
        logger.warning("没有标签数据，仅保存商品数据")
        
        # 保存商品数据用于手工标注
        products_path = "data/raw/products_for_annotation.json"
        with open(products_path, 'w', encoding='utf-8') as f:
            json.dump(processed_products, f, ensure_ascii=False, indent=2)
        
        logger.info(f"商品数据已保存到: {products_path}")
        logger.info("请手工标注后再次运行此脚本")


if __name__ == "__main__":
    prepare_training_data()
