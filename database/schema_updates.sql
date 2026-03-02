-- 商品详情介绍和评价功能数据库更新脚本
-- 执行时间：2026-02-28
-- 说明：新增商品详情文字介绍表和商品评价表

USE health_mall_system;

-- 1. 创建商品详情文字介绍表
CREATE TABLE IF NOT EXISTS `product_descriptions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '详情介绍唯一标识',
    `product_id` INT NOT NULL COMMENT '商品 ID，关联 products 表',
    `content` TEXT NOT NULL COMMENT '商品详细文字介绍内容',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE,
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品详情文字介绍表';

-- 2. 创建商品评价表
CREATE TABLE IF NOT EXISTS `product_reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '评价唯一标识',
    `product_id` INT NOT NULL COMMENT '商品 ID，关联 products 表',
    `user_id` INT NOT NULL COMMENT '用户 ID，关联 users 表',
    `rating` TINYINT NOT NULL COMMENT '评分 (1-5)',
    `title` VARCHAR(200) DEFAULT NULL COMMENT '评价标题',
    `content` TEXT DEFAULT NULL COMMENT '评价内容',
    `is_anonymous` BOOLEAN DEFAULT FALSE COMMENT '是否匿名评价',
    `status` ENUM('APPROVED', 'PENDING', 'REJECTED') DEFAULT 'APPROVED' COMMENT '评价状态：APPROVED-已通过，PENDING-待审核，REJECTED-已拒绝',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_rating` (`rating`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品评价表';

-- 3. 在 products 表中添加评分统计字段（可选，用于缓存商品的平均评分和评价数量）
ALTER TABLE `products` 
ADD COLUMN `average_rating` DECIMAL(3,2) DEFAULT 0.00 COMMENT '商品平均评分' AFTER `sales`,
ADD COLUMN `review_count` INT DEFAULT 0 COMMENT '评价数量' AFTER `average_rating`;

-- 4. 创建评分统计索引
ALTER TABLE `products` ADD INDEX `idx_average_rating` (`average_rating`);

-- 5. 插入测试数据（可选）
-- 为商品 ID 为 1 的商品添加详情介绍
INSERT INTO `product_descriptions` (`product_id`, `content`) 
VALUES (1, '这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。适合日常保健，增强身体抵抗力。')
ON DUPLICATE KEY UPDATE `content` = VALUES(`content`);

-- 为商品 ID 为 1 的商品添加测试评价
INSERT INTO `product_reviews` (`product_id`, `user_id`, `rating`, `title`, `content`, `is_anonymous`, `status`) 
VALUES 
(1, 1, 5, '非常好的产品', '吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！', FALSE, 'APPROVED'),
(1, 2, 4, '效果不错', '味道可以接受，每天一片，希望长期坚持有效果。', FALSE, 'APPROVED'),
(1, 3, 5, '值得购买', '大品牌值得信赖，家人都在吃，会继续回购的。', FALSE, 'APPROVED')
ON DUPLICATE KEY UPDATE `content` = VALUES(`content`);

-- 更新商品评分统计
UPDATE `products` 
SET 
    `average_rating` = (SELECT AVG(`rating`) FROM `product_reviews` WHERE `product_id` = products.id AND `status` = 'APPROVED'),
    `review_count` = (SELECT COUNT(*) FROM `product_reviews` WHERE `product_id` = products.id AND `status` = 'APPROVED')
WHERE `id` = 1;
