-- 使用 UTF-8 编码插入测试商品数据
-- 避免外键约束问题

USE health_mall_system;

-- 删除现有商品数据（不使用 TRUNCATE）
DELETE FROM products;

-- 插入测试商品数据（使用简单的中文）
INSERT INTO products (merchant_id, title, category, description, cover_url, features, description_content, price, stock, sales, average_rating, review_count, status, auto_confirm_mode, created_at, updated_at)
VALUES 
(4, '维生素C片', '保健品', '补充维生素C', 'http://localhost:8080/v1/static/test/vc.jpg', '{}', '增强免疫力', 59.9, 100, 50, 4.5, 10, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '深海鱼油', '保健品', 'Omega-3脂肪酸', 'http://localhost:8080/v1/static/test/fish.jpg', '{}', '保护心血管', 128.0, 80, 30, 4.6, 8, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '钙片', '保健品', '补充钙质', 'http://localhost:8080/v1/static/test/calcium.jpg', '{}', '强健骨骼', 89.5, 120, 40, 4.7, 12, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '益生菌', '保健品', '调节肠道', 'http://localhost:8080/v1/static/test/probiotics.jpg', '{}', '改善消化', 199.0, 60, 25, 4.8, 15, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '胶原蛋白', '保健品', '美容养颜', 'http://localhost:8080/v1/static/test/collagen.jpg', '{}', '保持肌肤弹性', 258.0, 90, 35, 4.4, 9, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '复合维生素', '保健品', '全面营养', 'http://localhost:8080/v1/static/test/vitamin.jpg', '{}', '每日一片', 45.0, 150, 60, 4.6, 18, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '褪黑素', '保健品', '改善睡眠', 'http://localhost:8080/v1/static/test/melatonin.jpg', '{}', '助眠安神', 79.0, 110, 45, 4.5, 14, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '辅酶Q10', '保健品', '保护心脏', 'http://localhost:8080/v1/static/test/q10.jpg', '{}', '抗氧化', 299.0, 70, 20, 4.9, 7, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '氨糖软骨素', '保健品', '关节健康', 'http://localhost:8080/v1/static/test/joint.jpg', '{}', '修复关节', 218.0, 85, 28, 4.7, 11, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '叶酸片', '保健品', '备孕营养', 'http://localhost:8080/v1/static/test/folic.jpg', '{}', '预防神经管缺陷', 35.0, 200, 80, 4.8, 16, 'ON_SALE', 'MANUAL', NOW(), NOW());

-- 显示插入结果
SELECT '测试数据插入完成！' as Status;
SELECT COUNT(*) as ProductCount FROM products;
SELECT id, title, category, price FROM products;
