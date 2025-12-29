-- 更新用户表，添加email和phone字段
USE health_mall_system;

ALTER TABLE `users` 
ADD COLUMN `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱地址' AFTER `avatar_url`,
ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码' AFTER `email`;
