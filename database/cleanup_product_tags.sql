-- 清理商品标签数据中的异常格式
USE health_mall_system;

-- 1. 查看当前所有商品的features字段格式
SELECT 
    id, 
    title, 
    features,
    CASE 
        WHEN features IS NULL THEN 'NULL'
        WHEN features = '[]' THEN '空数组'
        WHEN features = '{}' THEN '空对象'
        WHEN features LIKE '[%' THEN '有效数组'
        WHEN features LIKE '{%' THEN 'JSON对象（错误）'
        ELSE '其他格式（错误）'
    END as '格式类型'
FROM products
WHERE features IS NOT NULL
ORDER BY id;

-- 2. 清理格式错误的features字段（将JSON对象和普通字符串清空）
UPDATE products 
SET features = NULL 
WHERE features IS NOT NULL 
  AND features != '[]' 
  AND features != '{}' 
  AND features NOT LIKE '[%';

-- 3. 为测试商品ID=1设置正确的标签格式
UPDATE products 
SET features = '["维生素", "增强免疫力", "抗氧化", "天然原料", "健康"]'
WHERE id = 1;

-- 4. 为其他测试商品设置示例标签
UPDATE products 
SET features = '["保健品", "营养补充", "健康"]'
WHERE id IN (2, 3);

-- 5. 清理features为空对象的记录
UPDATE products 
SET features = NULL 
WHERE features = '{}';

-- 6. 验证清理结果
SELECT 
    id, 
    title, 
    features,
    CASE 
        WHEN features IS NULL THEN 'NULL'
        WHEN features = '[]' THEN '空数组'
        WHEN features LIKE '[%' THEN '有效数组'
        ELSE '其他'
    END as '格式类型'
FROM products
WHERE features IS NOT NULL
ORDER BY id
LIMIT 20;

SELECT '标签数据清理完成！' as 'Status';
