-- Database Seeding Script for Product Auto-Confirmation Mode Testing
-- This script creates test products with different autoConfirmMode values

USE health_mall_system;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Insert test products with AUTO mode
INSERT INTO products (merchant_id, title, category, description, cover_url, features, price, stock, sales, status, auto_confirm_mode, auto_confirm_condition, created_at, updated_at)
VALUES 
(4, 'Test Product - Auto Confirm 1', '保健品', '自动确认测试商品1', 'http://localhost:8080/v1/static/test/auto1.jpg', '天然提取', 99.00, 100, 0, 'AUTO', NULL, NOW(), NOW()),
(4, 'Test Product - Auto Confirm 2', '保健品', '自动确认测试商品2', 'http://localhost:8080/v1/static/test/auto2.jpg', '无添加', 149.00, 80, 0, 'AUTO', NULL, NOW(), NOW());

-- Insert test products with MANUAL mode
INSERT INTO products (merchant_id, title, category, description, cover_url, features, price, stock, sales, status, auto_confirm_mode, auto_confirm_condition, created_at, updated_at)
VALUES 
(4, 'Test Product - Manual Confirm 1', '保健品', '手动确认测试商品1', 'http://localhost:8080/v1/static/test/manual1.jpg', '有机认证', 199.00, 50, 0, 'MANUAL', NULL, NOW(), NOW()),
(4, 'Test Product - Manual Confirm 2', '保健品', '手动确认测试商品2', 'http://localhost:8080/v1/static/test/manual2.jpg', '进口原料', 299.00, 30, 0, 'MANUAL', NULL, NOW(), NOW());

-- Insert test products with SMART mode
INSERT INTO products (merchant_id, title, category, description, cover_url, features, price, stock, sales, status, auto_confirm_mode, auto_confirm_condition, created_at, updated_at)
VALUES 
(4, 'Test Product - Smart Confirm 1', '保健品', '智能确认测试商品1', 'http://localhost:8080/v1/static/test/smart1.jpg', '高科技提取', 399.00, 200, 0, 'SMART', '{"minOrderAmount":100,"stockThreshold":10}', NOW(), NOW()),
(4, 'Test Product - Smart Confirm 2', '保健品', '智能确认测试商品2', 'http://localhost:8080/v1/static/test/smart2.jpg', '科学配方', 499.00, 150, 0, 'SMART', '{"minOrderAmount":50,"maxOrderAmount":500,"minUserRating":4.0,"stockThreshold":20}', NOW(), NOW()),
(4, 'Test Product - Smart Confirm 3', '保健品', '智能确认测试商品3', 'http://localhost:8080/v1/static/test/smart3.jpg', '临床验证', 599.00, 100, 0, 'SMART', '{"minOrderAmount":200,"stockThreshold":5}', NOW(), NOW());

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Display summary
SELECT 
    auto_confirm_mode as 'Auto Confirm Mode',
    COUNT(*) as 'Product Count',
    MIN(price) as 'Min Price',
    MAX(price) as 'Max Price'
FROM products
WHERE merchant_id = 4
GROUP BY auto_confirm_mode;

SELECT 'Database seeding completed successfully!' as 'Status';
