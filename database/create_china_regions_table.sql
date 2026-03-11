-- 中国行政区划表
-- 用于存储中国省、市、区县三级行政区划数据

CREATE TABLE IF NOT EXISTS china_regions (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
  province VARCHAR(50) NOT NULL COMMENT '省份名称',
  city VARCHAR(50) NOT NULL COMMENT '地级市名称',
  district VARCHAR(50) NOT NULL COMMENT '区/县/县级市名称',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_province (province),
  INDEX idx_city (city),
  INDEX idx_province_city (province, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='中国行政区划表';
