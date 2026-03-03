-- 修复订单表 status 列的 ENUM 定义
-- 添加缺失的订单状态以匹配 Java 代码中的 OrderStatus 枚举

USE health_mall_system;

-- 修改 status 列的 ENUM 定义，添加所有需要的状态
ALTER TABLE `orders` 
MODIFY COLUMN `status` ENUM(
    'PENDING_CONFIRMATION',  -- 待商家确认
    'CONFIRMED',              -- 商家已确认
    'REJECTED',               -- 商家已拒绝
    'PENDING_PAYMENT',        -- 待付款
    'PAID',                   -- 已付款
    'SHIPPED',                -- 已发货
    'DELIVERED',              -- 已送达
    'COMPLETED',              -- 已完成
    'CANCELLED',              -- 已取消
    'REFUNDED'                -- 已退款
) NOT NULL DEFAULT 'PENDING_CONFIRMATION' COMMENT '订单状态';

-- 验证修改
DESCRIBE orders;
