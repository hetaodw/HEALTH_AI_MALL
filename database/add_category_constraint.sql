USE health_mall_system;

ALTER TABLE products 
ADD CONSTRAINT chk_category 
CHECK (category IN ('保健品', '医疗器械', '健康食品', '运动健身', '母婴用品'));

SELECT '商品分类约束添加成功！' as 'Status';
