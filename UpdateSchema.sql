-- 为users表添加role字段
ALTER TABLE `users` ADD COLUMN `role` ENUM('USER', 'MERCHANT') DEFAULT 'USER' COMMENT '用户角色：USER-普通用户，MERCHANT-商家' AFTER `avatar_url`;

-- 为products表添加merchant_id字段
ALTER TABLE `products` ADD COLUMN `merchant_id` INT DEFAULT NULL COMMENT '商家ID' AFTER `id`;

-- 为products表添加sales字段
ALTER TABLE `products` ADD COLUMN `sales` INT DEFAULT 0 COMMENT '销量' AFTER `stock`;

-- 为products表添加status字段
ALTER TABLE `products` ADD COLUMN `status` ENUM('ON_SALE', 'OFF_SALE', 'OUT_OF_STOCK') DEFAULT 'ON_SALE' COMMENT '商品状态：ON_SALE-在售，OFF_SALE-下架，OUT_OF_STOCK-缺货' AFTER `sales`;

-- 为products表添加updated_at字段
ALTER TABLE `products` ADD COLUMN `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `status`;

-- 为products表添加外键约束
ALTER TABLE `products` ADD CONSTRAINT `fk_products_merchant` FOREIGN KEY (`merchant_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
