-- 1. 创建数据库（若尚未存在）
CREATE DATABASE IF NOT EXISTS health_mall_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 切换到刚创建的数据库
USE health_mall_system;

-- 2. 用户表：用于存储系统中的用户基本信息
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一标识',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '加密后的密码',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱地址',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT '用户头像地址',
    `role` ENUM('USER', 'MERCHANT','admin') DEFAULT 'USER' COMMENT '用户角色：USER-普通用户，MERCHANT-商家',
    `remarks` TEXT DEFAULT NULL COMMENT '备注信息',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 3. 商品表：用于保存商品的基本信息，包括名称、描述、封面图、价格和库存等
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '商品唯一标识',
    `merchant_id` INT DEFAULT NULL COMMENT '商家用户ID，关联users表',
    `title` VARCHAR(100) NOT NULL COMMENT '商品名称',
    `description` TEXT COMMENT '商品详细描述',
    `cover_url` VARCHAR(255) NOT NULL COMMENT '商品封面图片URL',
    `features` JSON DEFAULT NULL COMMENT '商品特征（暂时留空，使用JSON格式方便扩展）',
    `price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格',
    `stock` INT DEFAULT 0 COMMENT '库存',
    `sales` INT DEFAULT 0 COMMENT '销量',
    `status` ENUM('ON_SALE', 'OFF_SALE', 'OUT_OF_STOCK') DEFAULT 'ON_SALE' COMMENT '商品状态：ON_SALE-在售，OFF_SALE-下架，OUT_OF_STOCK-缺货',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '商品创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '商品更新时间',
    FOREIGN KEY (`merchant_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品基础信息表';

-- 4. 商品详情图片表：用于存储某商品的多张详情介绍图，并支持按顺序展示
CREATE TABLE `product_details_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '图片记录唯一标识',
    `product_id` INT NOT NULL COMMENT '所属商品ID',
    `image_url` VARCHAR(255) NOT NULL COMMENT '详情图片URL',
    `sort_order` INT DEFAULT 0 COMMENT '排序顺序，数值越小越靠前',
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品详细介绍图片表';

-- 5. 最热商品推荐表：用于维护首页展示的热门商品列表，通过外键关联商品表
CREATE TABLE `hot_products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '推荐记录唯一标识',
    `product_id` INT NOT NULL UNIQUE COMMENT '关联的商品ID',
    `hot_score` INT DEFAULT 0 COMMENT '热度分值或排序序号，用于排序展示',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页/最热商品推荐表';