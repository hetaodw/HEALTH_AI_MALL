-- 数据库修复脚本 - 修复用户认证相关问题
USE health_mall_system;

-- ============================================
-- 修复1: 确保 username 字段有唯一约束
-- ============================================

-- 1.1 先删除可能存在的重复用户名（保留ID最小的）
SELECT '=== 清理重复用户名 ===' AS '';

-- 创建临时表存储要删除的用户ID
CREATE TEMPORARY TABLE duplicate_users_to_delete AS
SELECT 
    u1.id
FROM users u1
INNER JOIN (
    SELECT username, MIN(id) as min_id
    FROM users
    GROUP BY username
    HAVING COUNT(*) > 1
) u2 ON u1.username = u2.username AND u1.id > u2.min_id;

-- 显示将要删除的重复用户
SELECT id, username, email, role FROM users WHERE id IN (SELECT id FROM duplicate_users_to_delete);

-- 删除重复用户（保留ID最小的）
DELETE FROM users WHERE id IN (SELECT id FROM duplicate_users_to_delete);

-- 删除临时表
DROP TEMPORARY TABLE IF EXISTS duplicate_users_to_delete;

-- 1.2 删除现有的唯一约束（如果存在）
SELECT '=== 删除现有约束 ===' AS '';
ALTER TABLE users DROP INDEX IF EXISTS username;

-- 1.3 添加唯一约束
SELECT '=== 添加唯一约束 ===' AS '';
ALTER TABLE users ADD UNIQUE INDEX idx_username (username);

-- ============================================
-- 修复2: 确保密码字段长度足够
-- ============================================
SELECT '=== 检查密码字段长度 ===' AS '';
ALTER TABLE users MODIFY COLUMN password VARCHAR(255) NOT NULL COMMENT '加密后的密码';

-- ============================================
-- 修复3: 创建测试账号（如果不存在）
-- ============================================
SELECT '=== 创建测试账号 ===' AS '';

-- 注意：这些密码是 BCrypt 加密的 'Test123456'
-- $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

INSERT IGNORE INTO users (username, password, email, phone, role, avatar_url, remarks) VALUES
('testuser1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testuser1@example.com', '13800138001', 'USER', NULL, '测试用户1'),
('testuser2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testuser2@example.com', '13800138002', 'USER', NULL, '测试用户2'),
('testuser3', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testuser3@example.com', '13800138003', 'USER', NULL, '测试用户3'),
('testmerchant1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testmerchant1@example.com', '13800138004', 'MERCHANT', NULL, '测试商家1'),
('testmerchant2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'testmerchant2@example.com', '13800138005', 'MERCHANT', NULL, '测试商家2');

-- ============================================
-- 验证修复结果
-- ============================================
SELECT '=== 验证修复结果 ===' AS '';

-- 检查唯一约束
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'health_mall_system' 
  AND TABLE_NAME = 'users'
  AND CONSTRAINT_TYPE = 'UNIQUE';

-- 检查测试账号
SELECT 
    id,
    username,
    LEFT(password, 30) as password_preview,
    email,
    phone,
    role
FROM users
WHERE username IN ('testuser1', 'testmerchant1')
ORDER BY id;

-- 检查是否还有重复用户名
SELECT 
    username,
    COUNT(*) as count
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

SELECT '=== 修复完成 ===' AS '';
SELECT '请重启应用程序并重新运行测试' AS '';
