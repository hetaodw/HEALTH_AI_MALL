-- 订单系统扩展表结构
-- 执行前请确保备份数据

-- 1. 用户收货地址表
CREATE TABLE IF NOT EXISTS `addresses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '地址ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `receiver_name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `province` VARCHAR(50) DEFAULT NULL COMMENT '省份',
    `city` VARCHAR(50) DEFAULT NULL COMMENT '城市',
    `district` VARCHAR(50) DEFAULT NULL COMMENT '区/县',
    `detail_address` VARCHAR(255) NOT NULL COMMENT '详细地址',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认地址',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_user_id` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户收货地址表';

-- 2. 商品快照表（保存下单时的商品信息）
CREATE TABLE IF NOT EXISTS `product_snapshots` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '快照ID',
    `product_id` INT NOT NULL COMMENT '原商品ID',
    `title` VARCHAR(100) NOT NULL COMMENT '商品名称快照',
    `category` VARCHAR(50) DEFAULT NULL COMMENT '分类快照',
    `cover_url` VARCHAR(255) DEFAULT NULL COMMENT '封面图快照',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '价格快照',
    `merchant_id` INT DEFAULT NULL COMMENT '商家ID快照',
    `merchant_name` VARCHAR(50) DEFAULT NULL COMMENT '商家名称快照',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品快照表';

-- 3. 订单项表（支持一个订单多个商品）
CREATE TABLE IF NOT EXISTS `order_items` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '订单项ID',
    `order_id` INT NOT NULL COMMENT '订单ID',
    `product_id` INT NOT NULL COMMENT '商品ID',
    `snapshot_id` BIGINT NOT NULL COMMENT '商品快照ID',
    `quantity` INT NOT NULL COMMENT '购买数量',
    `unit_price` DECIMAL(10, 2) NOT NULL COMMENT '单价（快照价格）',
    `total_price` DECIMAL(10, 2) NOT NULL COMMENT '小计金额',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`snapshot_id`) REFERENCES `product_snapshots`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单项表';

-- 4. 库存预占记录表
CREATE TABLE IF NOT EXISTS `stock_reservations` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '预占ID',
    `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
    `product_id` INT NOT NULL COMMENT '商品ID',
    `quantity` INT NOT NULL COMMENT '预占数量',
    `status` ENUM('RESERVED', 'CONFIRMED', 'RELEASED') DEFAULT 'RESERVED' COMMENT '状态：RESERVED-已预占，CONFIRMED-已确认，RELEASED-已释放',
    `expire_at` TIMESTAMP NOT NULL COMMENT '过期时间',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX `idx_order_product` (`order_no`, `product_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_expire_at` (`expire_at`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存预占记录表';

-- 5. 修改订单表结构
ALTER TABLE `orders` 
    DROP COLUMN `product_id`,
    DROP COLUMN `quantity`,
    DROP COLUMN `unit_price`,
    ADD COLUMN `address_id` INT DEFAULT NULL COMMENT '收货地址ID' AFTER `user_id`,
    ADD COLUMN `item_count` INT DEFAULT 0 COMMENT '商品种类数' AFTER `total_amount`,
    ADD COLUMN `pay_expire_at` TIMESTAMP NULL COMMENT '支付过期时间' AFTER `status`,
    ADD COLUMN `cancelled_at` TIMESTAMP NULL COMMENT '取消时间' AFTER `completed_at`,
    ADD COLUMN `cancel_reason` VARCHAR(255) DEFAULT NULL COMMENT '取消原因' AFTER `cancelled_at`;

-- 添加地址外键
ALTER TABLE `orders` 
    ADD CONSTRAINT `fk_order_address` FOREIGN KEY (`address_id`) REFERENCES `addresses`(`id`) ON DELETE SET NULL;

-- 6. 支付记录表
CREATE TABLE IF NOT EXISTS `payments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '支付ID',
    `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
    `pay_no` VARCHAR(64) DEFAULT NULL COMMENT '支付流水号',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    `pay_method` VARCHAR(20) DEFAULT NULL COMMENT '支付方式',
    `status` ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') DEFAULT 'PENDING' COMMENT '支付状态',
    `paid_at` TIMESTAMP NULL COMMENT '支付时间',
    `notify_data` TEXT DEFAULT NULL COMMENT '支付回调数据',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX `idx_order_no` (`order_no`),
    INDEX `idx_pay_no` (`pay_no`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';
