-- 添加商家确认订单功能相关字段
ALTER TABLE orders 
ADD COLUMN confirmed_at TIMESTAMP NULL COMMENT '商家确认时间' AFTER paid_at,
ADD COLUMN rejected_at TIMESTAMP NULL COMMENT '商家拒绝时间' AFTER confirmed_at,
ADD COLUMN reject_reason VARCHAR(255) DEFAULT NULL COMMENT '拒绝原因' AFTER rejected_at,
ADD COLUMN auto_confirmed BOOLEAN DEFAULT FALSE COMMENT '是否自动确认' AFTER reject_reason;
