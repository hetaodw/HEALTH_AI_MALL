-- Database Cleanup Script for Product Auto-Confirmation Mode Testing
-- This script removes test products created during testing

USE health_mall_system;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Delete test products (products with "Test Product" in title)
DELETE FROM product_details_images 
WHERE product_id IN (
    SELECT id FROM products 
    WHERE title LIKE 'Test Product%'
);

DELETE FROM product_descriptions 
WHERE product_id IN (
    SELECT id FROM products 
    WHERE title LIKE 'Test Product%'
);

DELETE FROM product_reviews 
WHERE product_id IN (
    SELECT id FROM products 
    WHERE title LIKE 'Test Product%'
);

DELETE FROM order_items 
WHERE product_id IN (
    SELECT id FROM products 
    WHERE title LIKE 'Test Product%'
);

DELETE FROM products 
WHERE title LIKE 'Test Product%';

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Display summary
SELECT CONCAT('Deleted ', ROW_COUNT(), ' test products') as 'Status';
SELECT 'Database cleanup completed successfully!' as 'Status';
