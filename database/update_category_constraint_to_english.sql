USE health_mall_system;

ALTER TABLE products DROP CONSTRAINT IF EXISTS chk_category;

ALTER TABLE products 
ADD CONSTRAINT chk_category 
CHECK (category IN ('HEALTH_PRODUCTS', 'MEDICAL_DEVICES', 'HEALTH_FOOD', 'SPORTS_FITNESS', 'MATERNAL_BABY'));

SELECT 'Category constraint updated to English!' as 'Status';
