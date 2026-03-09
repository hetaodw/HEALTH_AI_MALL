-- 健康商城系统测试数据插入SQL
-- 适配当前数据库结构

USE health_mall_system;

-- 插入测试用户数据
INSERT INTO users (username, password, email, avatar_url, role, remarks) VALUES
('testuser1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKI', 'testuser1@example.com', '/avatars/user001.jpg', 'USER', '普通测试用户1'),
('testuser2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKI', 'testuser2@example.com', '/avatars/user002.jpg', 'USER', '普通测试用户2'),
('testuser3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKI', 'testuser3@example.com', '/avatars/user003.jpg', 'USER', '普通测试用户3'),
('testmerchant1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKI', 'testmerchant1@example.com', '/avatars/merchant001.jpg', 'MERCHANT', '测试商家1'),
('testmerchant2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKI', 'testmerchant2@example.com', '/avatars/merchant002.jpg', 'MERCHANT', '测试商家2');

-- 插入测试地址数据
INSERT INTO addresses (user_id, receiver_name, receiver_phone, province, city, district, detail_address, is_default) VALUES
(1, '张三', '13800138001', '北京市', '北京市', '朝阳区', '朝阳路123号', 1),
(1, '张三', '13800138001', '北京市', '北京市', '海淀区', '中关村大街456号', 0),
(2, '李四', '13800138002', '上海市', '上海市', '浦东新区', '陆家嘴环路789号', 1),
(3, '王五', '13800138003', '广东省', '深圳市', '南山区', '科技园南区101号', 1),
(4, '赵六', '13800138004', '浙江省', '杭州市', '西湖区', '文三路202号', 1);

-- 插入测试商品评价数据
INSERT INTO product_reviews (product_id, user_id, rating, content, is_anonymous, created_at) VALUES
(1, 1, 5, '非常好用的产品，效果明显！', 0, NOW()),
(1, 2, 4, '质量不错，物流也很快', 1, NOW()),
(2, 1, 5, '性价比很高，推荐购买', 0, NOW()),
(2, 3, 4, '包装完好，产品正宗', 1, NOW()),
(3, 2, 5, '第三次购买了，一如既往的好', 0, NOW()),
(3, 4, 4, '效果还可以，继续观察', 1, NOW()),
(4, 1, 5, '味道不错，孩子喜欢', 0, NOW()),
(4, 3, 4, '价格实惠，质量放心', 1, NOW()),
(5, 2, 5, '包装精美，送礼很合适', 0, NOW()),
(5, 4, 4, '客服态度好，解答耐心', 1, NOW());

-- 显示插入结果
SELECT '测试数据插入完成！' as 'Status';
SELECT '用户数据' as 'Table', COUNT(*) as 'Count' FROM users
UNION ALL
SELECT '地址数据', COUNT(*) FROM addresses
UNION ALL
SELECT '商品评价', COUNT(*) FROM product_reviews;

-- 显示测试账号信息
SELECT 
    id as '用户ID',
    username as '用户名',
    email as '邮箱',
    role as '角色',
    'Test123456' as '密码'
FROM users 
WHERE username LIKE 'test%'
ORDER BY id;
