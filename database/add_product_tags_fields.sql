-- 为 products 表添加标签相关字段
-- 执行时间：2026-03-04
-- 说明：支持商品标签AI生成功能

USE health_mall_system;

-- 添加 need_regenerate_tags 字段
-- 用于标记商品是否需要重新生成标签（标题或描述修改后标记为true）
ALTER TABLE `products` 
ADD COLUMN `need_regenerate_tags` TINYINT(1) DEFAULT 0 COMMENT '是否需要重新生成标签：0-否，1-是' AFTER `auto_confirm_condition`;

-- 为 need_regenerate_tags 字段添加索引以优化查询性能
ALTER TABLE `products` ADD INDEX `idx_need_regenerate_tags` (`need_regenerate_tags`);

-- 说明：
-- 1. features 字段将仅存储标签数组，格式如：["维生素", "增强免疫力", "抗氧化"]
-- 2. need_regenerate_tags=1 的商品会在定时任务中被处理
-- 3. 新增商品默认 need_regenerate_tags=0（添加时立即生成标签）
-- 4. 更新商品标题/描述时设置 need_regenerate_tags=1

-- 显示执行结果
SELECT 'need_regenerate_tags 字段添加成功！' as 'Status';
SELECT COUNT(*) as 'Total Products' FROM `products`;
