-- 商品自动确认模式功能数据库更新脚本
-- 执行时间：2026-03-03
-- 说明：为商品表添加自动确认模式字段，支持商家配置订单自动确认策略

USE health_mall_system;

-- 1. 在 products 表中添加自动确认模式字段
ALTER TABLE `products` 
ADD COLUMN `auto_confirm_mode` ENUM('AUTO', 'MANUAL', 'SMART') DEFAULT 'MANUAL' 
COMMENT '自动确认模式：AUTO-自动确认，MANUAL-手动确认，SMART-智能确认' 
AFTER `status`;

-- 2. 在 products 表中添加智能确认条件字段
ALTER TABLE `products` 
ADD COLUMN `auto_confirm_condition` TEXT DEFAULT NULL 
COMMENT '智能确认条件（JSON格式），仅在SMART模式下有效' 
AFTER `auto_confirm_mode`;

-- 3. 添加索引以优化查询性能
CREATE INDEX `idx_auto_confirm_mode` ON `products`(`auto_confirm_mode`);

-- 4. 更新现有商品数据（可选：将所有现有商品设置为手动确认模式）
-- UPDATE `products` SET `auto_confirm_mode` = 'MANUAL' WHERE `auto_confirm_mode` IS NULL;

-- 5. 添加注释说明
ALTER TABLE `products` MODIFY COLUMN `auto_confirm_mode` ENUM('AUTO', 'MANUAL', 'SMART') 
DEFAULT 'MANUAL' 
COMMENT '自动确认模式：
- AUTO: 库存充足时自动确认订单
- MANUAL: 所有订单都需要商家手动确认（默认）
- SMART: 根据订单条件智能判断是否自动确认';

-- 6. 添加CHECK约束（MySQL 8.0+支持）
-- ALTER TABLE `products` 
-- ADD CONSTRAINT `chk_auto_confirm_mode` 
-- CHECK (`auto_confirm_mode` IN ('AUTO', 'MANUAL', 'SMART'));

-- 示例数据：为商品设置不同的自动确认模式
-- 商品ID为1的商品设置为自动确认模式
-- UPDATE `products` SET `auto_confirm_mode` = 'AUTO' WHERE `id` = 1;

-- 商品ID为2的商品设置为智能确认模式，并配置条件
-- UPDATE `products` 
-- SET 
--     `auto_confirm_mode` = 'SMART',
--     `auto_confirm_condition` = '{
--         "minOrderAmount": 100.00,
--         "maxOrderAmount": 1000.00,
--         "minUserRating": 4.0,
--         "minUserOrders": 5,
--         "stockThreshold": 10,
--         "timeRanges": [
--             {"start": "09:00", "end": "18:00"}
--         ]
--     }'
-- WHERE `id` = 2;

-- 验证脚本执行结果
SELECT 
    id,
    title,
    auto_confirm_mode,
    auto_confirm_condition
FROM `products`
LIMIT 10;
