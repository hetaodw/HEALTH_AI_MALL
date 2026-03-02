# 健康商城系统数据库结构说明

## 概述

本文档详细描述了健康商城系统（health_mall_system）的数据库结构，包括表设计、字段说明、关联关系和索引信息。

- **数据库名称**: `health_mall_system`
- **字符集**: `utf8mb4`
- **排序规则**: `utf8mb4_unicode_ci`
- **存储引擎**: `InnoDB`

---

## 表结构概览

| 表名 | 说明 | 记录数预估 |
|------|------|-----------|
| `users` | 用户信息表 | 万级 |
| `products` | 商品基础信息表 | 千级 |
| `product_details_images` | 商品详情图片表 | 万级 |
| `product_descriptions` | 商品详情文字介绍表 | 千级 |
| `product_reviews` | 商品评价表 | 万级 |
| `hot_products` | 首页热门商品推荐表 | 十级 |

---

## 详细表结构

### 1. users - 用户信息表

存储系统中的用户基本信息，支持普通用户和商家两种角色。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 用户唯一标识 |
| `username` | VARCHAR(50) | NOT NULL, UNIQUE | - | 用户名 |
| `password` | VARCHAR(255) | NOT NULL | - | 加密后的密码（BCrypt） |
| `email` | VARCHAR(100) | NULL | NULL | 邮箱地址 |
| `phone` | VARCHAR(20) | NULL | NULL | 手机号码 |
| `avatar_url` | VARCHAR(255) | NULL | NULL | 用户头像URL |
| `role` | ENUM | NULL | 'USER' | 用户角色：USER-普通用户，MERCHANT-商家，admin-管理员 |
| `remarks` | TEXT | NULL | NULL | 备注信息 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 注册时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `username`

---

### 2. products - 商品基础信息表

存储商品的基本信息，包括名称、描述、价格、库存等。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 商品唯一标识 |
| `merchant_id` | INT | FOREIGN KEY | NULL | 商家用户ID，关联users表 |
| `title` | VARCHAR(100) | NOT NULL | - | 商品名称 |
| `description` | TEXT | NULL | NULL | 商品详细描述 |
| `cover_url` | VARCHAR(255) | NOT NULL | - | 商品封面图片URL |
| `features` | JSON | NULL | NULL | 商品特征（JSON格式，便于扩展） |
| `price` | DECIMAL(10,2) | NOT NULL | 0.00 | 商品价格 |
| `stock` | INT | NULL | 0 | 库存数量 |
| `sales` | INT | NULL | 0 | 销量统计 |
| `average_rating` | DECIMAL(3,2) | NULL | 0.00 | 商品平均评分 (0-5) |
| `review_count` | INT | NULL | 0 | 评价数量 |
| `status` | ENUM | NULL | 'ON_SALE' | 商品状态：ON_SALE-在售，OFF_SALE-下架，OUT_OF_STOCK-缺货 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 商品创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 商品更新时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `merchant_id` → `users(id)`
- 建议索引: `status` + `created_at`（商品列表查询）
- 建议索引: `merchant_id` + `status`（商家商品管理）

**外键约束**:
```sql
FOREIGN KEY (`merchant_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
```

---

### 3. product_details_images - 商品详情图片表

存储商品的多张详情介绍图，支持按顺序展示。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 图片记录唯一标识 |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 所属商品ID |
| `image_url` | VARCHAR(255) | NOT NULL | - | 详情图片URL |
| `sort_order` | INT | NULL | 0 | 排序顺序，数值越小越靠前 |

**索引**:
- 主键索引: `id`
- 外键索引: `product_id` → `products(id)`
- 建议索引: `product_id` + `sort_order`（详情图片查询）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
```

---

### 5. product_descriptions - 商品详情文字介绍表

存储商品的详细文字介绍内容，每个商品只能有一条详情介绍。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 详情介绍唯一标识 |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品 ID，关联 products 表 |
| `content` | TEXT | NOT NULL | - | 商品详细文字介绍内容 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引**:
- 主键索引：`id`
- 外键索引：`product_id` → `products(id)`
- 建议索引：`product_id`（商品详情查询）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
```

---

### 6. product_reviews - 商品评价表

存储用户对商品的评价信息，包括评分、评价内容等。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 评价唯一标识 |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品 ID，关联 products 表 |
| `user_id` | INT | FOREIGN KEY, NOT NULL | - | 用户 ID，关联 users 表 |
| `rating` | TINYINT | NOT NULL | - | 评分 (1-5) |
| `title` | VARCHAR(200) | NULL | NULL | 评价标题 |
| `content` | TEXT | NULL | NULL | 评价内容 |
| `is_anonymous` | BOOLEAN | NULL | FALSE | 是否匿名评价 |
| `status` | ENUM | NULL | 'APPROVED' | 评价状态：APPROVED-已通过，PENDING-待审核，REJECTED-已拒绝 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引**:
- 主键索引：`id`
- 外键索引：`product_id` → `products(id)`
- 外键索引：`user_id` → `users(id)`
- 建议索引：`product_id` + `status` + `created_at`（商品评价列表查询）
- 建议索引：`user_id`（用户评价查询）
- 建议索引：`status`（评价审核查询）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
```

---

### 7. hot_products - 首页热门商品推荐表

维护首页展示的热门商品列表，通过外键关联商品表。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 推荐记录唯一标识 |
| `product_id` | INT | FOREIGN KEY, NOT NULL, UNIQUE | - | 关联的商品ID |
| `hot_score` | INT | NULL | 0 | 热度分值或排序序号 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 最后更新时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `product_id`
- 建议索引: `hot_score`（热门商品排序）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
```

---

## ER 关系图

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────────────┐
│     users       │         │    products     │         │ product_details_images  │
├─────────────────┤         ├─────────────────┤         ├─────────────────────────┤
│ PK id           │◄────────┤ FK merchant_id  │◄────────┤ FK product_id           │
│    username     │   1:N   │    title        │   1:N   │    image_url            │
│    role         │         │    price        │         │    sort_order           │
│    ...          │         │    status       │         │                         │
└─────────────────┘         └─────────────────┘         └─────────────────────────┘
         ▲                       │
         │                       │ 1:1
         │                       │
         │              ┌─────────────────┐
         │              │  hot_products   │
         │              ├─────────────────┤
         │              │ PK id           │
         │              │ FK product_id   │
         │              │    hot_score    │
         │              └─────────────────┘
         │                       │
         │                       │ 1:1
         │                       │
         │              ┌─────────────────────────┐
         │              │ product_descriptions    │
         │              ├─────────────────────────┤
         │              │ PK id                   │
         │              │ FK product_id           │
         │              │    content              │
         │              └─────────────────────────┘
         │                       │
         │                       │ 1:N
         │                       │
         │              ┌─────────────────────────┐
         │              │    product_reviews      │
         │              ├─────────────────────────┤
         │              │ PK id                   │
         │              │ FK product_id           │
         │              │ FK user_id              │
         │              │    rating               │
         │              │    content              │
         │              └─────────────────────────┘
```

---

## 关系说明

| 主表 | 从表 | 关系类型 | 关联字段 | 级联操作 |
|------|------|----------|----------|----------|
| users | products | 1:N | users.id = products.merchant_id | ON DELETE SET NULL |
| products | product_details_images | 1:N | products.id = product_details_images.product_id | ON DELETE CASCADE |
| products | hot_products | 1:1 | products.id = hot_products.product_id | ON DELETE CASCADE |
| products | product_descriptions | 1:1 | products.id = product_descriptions.product_id | ON DELETE CASCADE |
| products | product_reviews | 1:N | products.id = product_reviews.product_id | ON DELETE CASCADE |
| users | product_reviews | 1:N | users.id = product_reviews.user_id | ON DELETE CASCADE |

---

## 常用查询示例

### 查询商品列表（带商家信息）
```sql
SELECT 
    p.id,
    p.title,
    p.price,
    p.stock,
    p.status,
    p.cover_url,
    u.username as merchant_name
FROM products p
LEFT JOIN users u ON p.merchant_id = u.id
WHERE p.status = 'ON_SALE'
ORDER BY p.created_at DESC;
```

### 查询商品详情（含详情图片）
```sql
SELECT 
    p.*,
    u.username as merchant_name,
    u.avatar_url as merchant_avatar
FROM products p
LEFT JOIN users u ON p.merchant_id = u.id
WHERE p.id = ?;

-- 查询详情图片
SELECT image_url, sort_order 
FROM product_details_images 
WHERE product_id = ? 
ORDER BY sort_order;
```

### 查询热门商品
```sql
SELECT 
    p.id,
    p.title,
    p.price,
    p.cover_url,
    h.hot_score
FROM hot_products h
JOIN products p ON h.product_id = p.id
WHERE p.status = 'ON_SALE'
ORDER BY h.hot_score DESC;
```

### 查询商品详情介绍
```sql
SELECT 
    pd.id,
    pd.product_id,
    pd.content,
    pd.created_at,
    pd.updated_at
FROM product_descriptions pd
WHERE pd.product_id = ?;
```

### 查询商品评价列表（带用户信息）
```sql
SELECT 
    pr.id,
    pr.product_id,
    pr.user_id,
    pr.rating,
    pr.title,
    pr.content,
    pr.is_anonymous,
    pr.status,
    pr.created_at,
    u.username,
    u.avatar_url
FROM product_reviews pr
LEFT JOIN users u ON pr.user_id = u.id
WHERE pr.product_id = ? 
  AND pr.status = 'APPROVED'
ORDER BY pr.created_at DESC
LIMIT ? OFFSET ?;
```

### 查询商品评分统计
```sql
SELECT 
    AVG(rating) as average_rating,
    COUNT(*) as review_count
FROM product_reviews
WHERE product_id = ? 
  AND status = 'APPROVED';
```

### 更新商品评分统计
```sql
UPDATE products p
SET 
    average_rating = (
        SELECT AVG(rating) 
        FROM product_reviews 
        WHERE product_id = p.id AND status = 'APPROVED'
    ),
    review_count = (
        SELECT COUNT(*) 
        FROM product_reviews 
        WHERE product_id = p.id AND status = 'APPROVED'
    )
WHERE p.id = ?;
```

---

## 数据库初始化

系统使用 Docker Compose 自动初始化数据库：

1. **启动时自动执行**: [Start.sql](../Start.sql)
2. **增量更新脚本**: [UpdateSchema.sql](../UpdateSchema.sql)

### 初始化配置（docker-compose.yml）

```yaml
mall-mysql:
  image: mysql:8.0
  environment:
    MYSQL_ROOT_PASSWORD: root123456
    MYSQL_DATABASE: health_mall_system
    MYSQL_USER: mall_user
    MYSQL_PASSWORD: mall_password
  volumes:
    - mysql-data:/var/lib/mysql
    - ./Start.sql:/docker-entrypoint-initdb.d/init.sql
  command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

---

## 维护建议

1. **定期备份**: 建议每日备份数据库
2. **索引优化**: 根据查询日志定期优化索引
3. **数据清理**: 定期清理已下架商品的详情图片
4. **监控告警**: 监控库存预警和热门商品变化
5. **评价管理**: 定期审核用户评价，清理虚假评价

---

*文档版本：2.0*
*最后更新：2026-02-28*
*更新内容：新增商品详情介绍表、商品评价表，更新商品表评分统计字段*
