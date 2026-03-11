-- Add Cainiao integration columns to logistics_info table
-- Migration script for Health Mall project

ALTER TABLE logistics_info 
ADD COLUMN cainiao_subscribed BOOLEAN DEFAULT FALSE COMMENT '是否已订阅菜鸟物流信息';

ALTER TABLE logistics_info 
ADD COLUMN cainiao_last_update DATETIME COMMENT '菜鸟最后更新时间';
