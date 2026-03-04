-- 数据库诊断脚本 - 检查 users 表的实际结构和约束
USE health_mall_system;

-- 1. 查看 users 表的完整结构
SELECT '=== users 表结构 ===' AS '';
DESCRIBE users;

-- 2. 查看 users 表的所有约束
SELECT '=== users 表约束 ===' AS '';
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'health_mall_system' 
  AND TABLE_NAME = 'users';

-- 3. 查看 users 表的索引
SELECT '=== users 表索引 ===' AS '';
SHOW INDEX FROM users;

-- 4. 检查是否有重复的用户名
SELECT '=== 检查重复用户名 ===' AS '';
SELECT 
    username,
    COUNT(*) as count,
    GROUP_CONCAT(id ORDER BY id) as user_ids
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- 5. 查看所有用户数据（前10条）
SELECT '=== 用户数据样本（前10条）===' AS '';
SELECT 
    id,
    username,
    LEFT(password, 20) as password_preview,
    email,
    phone,
    role,
    created_at
FROM users
ORDER BY id
LIMIT 10;

-- 6. 检查 testuser1 和 testmerchant1 的密码哈希
SELECT '=== 测试账号密码哈希 ===' AS '';
SELECT 
    id,
    username,
    password,
    role
FROM users
WHERE username IN ('testuser1', 'testmerchant1');

-- 7. 测试密码验证（需要手动执行）
-- 注意：这里只是展示，实际需要使用应用程序的密码编码器
SELECT '=== 密码验证说明 ===' AS '';
SELECT '请使用应用程序测试以下场景：' AS '';
SELECT '1. 使用 testuser1/Test123456 登录（应该成功）' AS '';
SELECT '2. 使用 testuser1/WrongPassword123 登录（应该失败）' AS '';
SELECT '3. 尝试注册已存在的用户名 testuser1（应该失败）' AS '';
