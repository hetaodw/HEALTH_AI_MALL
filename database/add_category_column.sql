-- 为 products 表添加 category 字段
-- 执行时间：2026-03-03
-- 说明：修复商品列表分类过滤问题

USE health_mall_system;

-- 添加 category 字段
ALTER TABLE `products` 
ADD COLUMN `category` VARCHAR(50) DEFAULT NULL COMMENT '商品分类' AFTER `merchant_id`;

-- 为 category 字段添加索引以优化查询性能
ALTER TABLE `products` ADD INDEX `idx_category` (`category`);

-- 为现有商品设置默认分类（可选）
-- UPDATE `products` SET `category` = '保健品' WHERE `category` IS NULL;

-- 显示执行结果
SELECT 'category 字段添加成功！' as 'Status';
SELECT COUNT(*) as 'Total Products', COUNT(`category`) as 'Products with Category' FROM `products`;
