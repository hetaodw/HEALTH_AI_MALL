-- 修复字符编码问题
USE health_mall_system;

-- 检查表字符集
SELECT 
    TABLE_NAME,
    TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'health_mall_system'
AND TABLE_NAME = 'products';

-- 删除乱码数据
DELETE FROM products WHERE id > 0;

-- 重新插入测试数据（使用正确的字符集）
INSERT INTO products (merchant_id, title, category, description, cover_url, features, description_content, price, stock, sales, average_rating, review_count, status, auto_confirm_mode, created_at, updated_at)
VALUES 
(4, '天然维生素 C 咀嚼片增强免疫力成人儿童适用橙味 100 片', 'HEALTH_PRODUCTS', '补充维 C 增强抵抗力，酸甜橙味', 'http://localhost:8080/v1/static/product/cover/health_products_1_1.jpg', '{"brand": "健康之源", "specification": "100 片/瓶", "origin": "中国"}', '精选天然针叶樱桃提取，每片含维生素 C 丰富，有助于维持免疫系统健康。适合成人及儿童日常补充，酸甜橙味易于接受，每日咀嚼即可。', 59.9, 320, 1580, 4.8, 156, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '深海鱼油软胶囊高纯度 Omega-3 辅助降血脂中老年保健品', 'HEALTH_PRODUCTS', '高纯度鱼油，呵护心脑血管健康', 'http://localhost:8080/v1/static/product/cover/health_products_1_2.jpg', '{"brand": "海洋之心", "specification": "60 粒/瓶", "origin": "新西兰"}', '源自深海纯净鱼油，富含 Omega-3 脂肪酸，有助于调节血脂，维护心血管健康。特别适合中老年人群日常保养，无腥味易吞咽，建议随餐服用。', 128.0, 150, 890, 4.7, 120, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '液体钙软胶囊维生素 D3 配合吸收骨骼健康成人老年人补钙', 'HEALTH_PRODUCTS', '液体钙易吸收，添加维 D 助钙质', 'http://localhost:8080/v1/static/product/cover/health_products_1_3.jpg', '{"brand": "骨力壮", "specification": "90 粒/瓶", "origin": "美国"}', '采用液体钙配方，比固体钙更易吸收利用。特别添加维生素 D3，促进钙质沉积于骨骼。适合骨质流失人群及老年人，预防骨质疏松，每日两粒。', 89.5, 200, 1200, 4.6, 98, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '成人益生菌粉调理肠道菌群改善便秘腹泻冻干粉技术存活率高', 'HEALTH_PRODUCTS', '调理肠道菌群，改善消化问题', 'http://localhost:8080/v1/static/product/cover/health_products_1_4.jpg', '{"brand": "肠乐舒", "specification": "30 袋/盒", "origin": "中国"}', '采用冻干技术锁定益生菌活性，直达肠道。含有多种有益菌株，帮助平衡肠道菌群，缓解便秘或腹泻不适。独立包装方便携带，温水冲服即可。', 199.0, 80, 650, 4.9, 180, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '胶原蛋白肽粉美容养颜保湿紧致肌肤女性口服营养补充剂', 'HEALTH_PRODUCTS', '补充胶原蛋白，保持肌肤弹性', 'http://localhost:8080/v1/static/product/cover/health_products_1_5.jpg', '{"brand": "美丽密码", "specification": "200g/罐", "origin": "日本"}', '小分子胶原蛋白肽，易于人体吸收利用。有助于改善皮肤水分，增加弹性，减少细纹。适合爱美女性日常内服保养，搭配维生素 C 效果更佳，无味易溶。', 258.0, 120, 430, 4.5, 85, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '男士复合维生素矿物质片多种营养补充抗疲劳增强体力精力', 'HEALTH_PRODUCTS', '专为男士设计，补充多种营养', 'http://localhost:8080/v1/static/product/cover/health_products_1_6.jpg', '{"brand": "劲能士", "specification": "60 片/瓶", "origin": "澳大利亚"}', '针对男性生理特点配方，含有多种维生素及矿物质，如锌、硒等。有助于缓解工作压力带来的疲劳感，增强体力与精力。每日一片，方便简单。', 145.0, 250, 980, 4.7, 110, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '女士复合维生素铁叶酸补充经期营养面色红润健康备孕可用', 'HEALTH_PRODUCTS', '补充铁质叶酸，呵护女性健康', 'http://localhost:8080/v1/static/product/cover/health_products_1_7.jpg', '{"brand": "丽人行", "specification": "90 片/瓶", "origin": "德国"}', '特别添加铁元素和叶酸，帮助改善面色苍白，补充经期流失营养。适合备孕及日常女性保养，维持身体代谢正常。温和配方，不刺激肠胃，每日推荐。', 168.0, 180, 760, 4.8, 145, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '褪黑素维生素 B6 片改善睡眠质量缓解失眠多梦成人非处方', 'HEALTH_PRODUCTS', '辅助改善睡眠，缓解失眠困扰', 'http://localhost:8080/v1/static/product/cover/health_products_1_8.jpg', '{"brand": "安睡宝", "specification": "60 片/瓶", "origin": "中国"}', '科学配比褪黑素与维生素 B6，有助于缩短入睡时间，改善睡眠质量。适合作息不规律或轻度失眠人群。非药物依赖，建议睡前半小时服用，不宜过量。', 79.0, 300, 1100, 4.4, 130, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '辅酶 Q10 软胶囊保护心脏健康抗氧化中老年心血管营养补充', 'HEALTH_PRODUCTS', '呵护心脏健康，强效抗氧化', 'http://localhost:8080/v1/static/product/cover/health_products_1_9.jpg', '{"brand": "心动力", "specification": "50 粒/瓶", "origin": "美国"}', '高含量辅酶 Q10，为心脏提供动力，有助于维护心血管系统健康。具有抗氧化作用，延缓细胞衰老。适合中老年人群及工作压力大者，随餐服用吸收好。', 299.0, 90, 320, 4.9, 75, 'ON_SALE', 'MANUAL', NOW(), NOW()),
(4, '氨糖软骨素钙片修复关节磨损缓解疼痛中老年父母关节健康', 'HEALTH_PRODUCTS', '修复关节软骨，缓解关节疼痛', 'http://localhost:8080/v1/static/product/cover/health_products_1_10.jpg', '{"brand": "关节灵", "specification": "120 片/瓶", "origin": "加拿大"}', '含有氨基葡萄糖和软骨素，有助于修复受损关节软骨，增加关节滑液。适合关节磨损、疼痛的中老年人群。配合钙质补充，增强骨骼强度，每日两次。', 218.0, 140, 550, 4.6, 92, 'ON_SALE', 'MANUAL', NOW(), NOW());

-- 显示插入结果
SELECT '字符编码修复完成！' as 'Status';
SELECT COUNT(*) as 'Product Count' FROM products;
SELECT id, title, category, price FROM products LIMIT 5;
