-- 商品详细文字介绍字段数据库更新脚本
-- 执行时间：2026-03-04
-- 说明：为商品表添加详细文字介绍字段，支持商家添加商品的详细文字描述

USE health_mall_system;

-- 1. 在 products 表中添加详细文字介绍字段
ALTER TABLE `products` 
ADD COLUMN `description_content` TEXT DEFAULT NULL 
COMMENT '商品详细文字介绍内容' 
AFTER `features`;

-- 2. 验证脚本执行结果
SELECT 
    id,
    title,
    description,
    description_content,
    features
FROM `products`
LIMIT 10;

-- 3. 示例：为现有商品添加详细文字介绍（可选）
-- UPDATE `products` 
-- SET `description_content` = '这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。适合日常保健，增强身体抵抗力。'
-- WHERE `id` = 1;
