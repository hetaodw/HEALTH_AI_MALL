USE health_mall_system;

UPDATE products SET category = '保健品' WHERE category = 'Health';

UPDATE products SET category = '保健品' WHERE category IS NULL OR category = '';

SELECT 'Category fix completed!' as Status;

SELECT category, COUNT(*) as count FROM products GROUP BY category;
