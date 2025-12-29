USE health_mall_system;

INSERT INTO products (title, description, cover_url, price, stock) VALUES
('天然维C片500mg', '富含维生素C，增强免疫力，抗氧化', 'https://example.com/products/vitamin_c.jpg', 98.00, 100),
('迪巧维D钙咀嚼片', '补充钙质，强健骨骼，适合成人', 'https://example.com/products/calcium.jpg', 68.00, 150),
('深海鱼油软胶囊', '富含Omega-3脂肪酸，保护心血管', 'https://example.com/products/fish_oil.jpg', 198.00, 80),
('胶原蛋白肽粉', '美容养颜，改善皮肤弹性', 'https://example.com/products/collagen.jpg', 128.00, 120),
('益生菌胶囊', '调节肠道菌群，改善消化', 'https://example.com/products/probiotics.jpg', 88.00, 200),
('辅酶Q10软胶囊', '保护心脏，增强体力', 'https://example.com/products/coenzyme_q10.jpg', 168.00, 90),
('维生素E软胶囊', '抗氧化，延缓衰老', 'https://example.com/products/vitamin_e.jpg', 58.00, 180),
('21金维他', '复合维生素，全面营养补充', 'https://example.com/products/multivitamin.jpg', 48.00, 250),
('锌片', '补充锌元素，增强免疫力', 'https://example.com/products/zinc.jpg', 38.00, 300),
('儿童益生菌', '专为儿童设计，调节肠胃', 'https://example.com/products/kids_probiotics.jpg', 78.00, 150),
('运动蛋白粉', '增肌减脂，适合健身人群', 'https://example.com/products/protein_powder.jpg', 298.00, 60),
('叶酸片', '孕期必备，预防胎儿神经管缺陷', 'https://example.com/products/folic_acid.jpg', 28.00, 200),
('益生元粉', '促进益生菌生长，改善肠道', 'https://example.com/products/prebiotics.jpg', 68.00, 120),
('氨糖软骨素', '保护关节，缓解关节疼痛', 'https://example.com/products/glucosamine.jpg', 158.00, 100),
('褪黑素片', '改善睡眠质量，缓解失眠', 'https://example.com/products/melatonin.jpg', 88.00, 180);

INSERT INTO hot_products (product_id, hot_score) VALUES
(1, 100),
(3, 95),
(5, 90),
(8, 85),
(12, 80);