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
| `product_discussions` | 商品讨论表 | 万级 |
| `hot_products` | 首页热门商品推荐表 | 十级 |
| `addresses` | 用户收货地址表 | 万级 |
| `product_snapshots` | 商品快照表 | 十万级 |
| `orders` | 订单表 | 十万级 |
| `order_items` | 订单项表 | 十万级 |
| `stock_reservations` | 库存预占记录表 | 十万级 |
| `payments` | 支付记录表 | 十万级 |
| `browsing_history` | 浏览记录表 | 十万级 |
| `logistics_info` | 物流信息表 | 十万级 |
| `operation_logs` | 操作日志表 | 百万级 |
| `risk_control_records` | 风控记录表 | 十万级 |

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
| `category` | VARCHAR(50) | NULL | NULL | 商品分类 |
| `description` | TEXT | NULL | NULL | 商品详细描述 |
| `cover_url` | VARCHAR(255) | NOT NULL | - | 商品封面图片URL |
| `features` | JSON | NULL | NULL | 商品特征（标签数组，JSON格式） |
| `description_content` | TEXT | NULL | NULL | 商品详细文字介绍内容 |
| `price` | DECIMAL(10,2) | NOT NULL | 0.00 | 商品价格 |
| `stock` | INT | NULL | 0 | 库存数量 |
| `sales` | INT | NULL | 0 | 销量统计 |
| `average_rating` | DECIMAL(3,2) | NULL | 0.00 | 商品平均评分 (0-5) |
| `review_count` | INT | NULL | 0 | 评价数量 |
| `status` | ENUM | NULL | 'ON_SALE' | 商品状态：ON_SALE-在售，OFF_SALE-下架，OUT_OF_STOCK-缺货 |
| `auto_confirm_mode` | ENUM | NULL | 'MANUAL' | 订单确认模式：AUTO-自动确认，MANUAL-手动确认，SMART-智能确认 |
| `auto_confirm_condition` | TEXT | NULL | NULL | 自动确认条件（JSON格式） |
| `need_regenerate_tags` | BOOLEAN | NULL | FALSE | 是否需要重新生成标签 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 商品创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 商品更新时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `merchant_id` → `users(id)`
- 建议索引: `status` + `created_at`（商品列表查询）
- 建议索引: `merchant_id` + `status`（商家商品管理）
- 建议索引: `category`（分类查询）
- 建议索引: `average_rating`（评分排序）
- 建议索引: `need_regenerate_tags`（标签生成任务查询）

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

### 7.1. product_discussions - 商品讨论表

存储用户对商品的讨论和问答信息，支持回复和点赞功能。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 讨论ID |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品ID，关联 products 表 |
| `user_id` | INT | FOREIGN KEY | NULL | 用户ID，关联 users 表 |
| `user_name` | VARCHAR(255) | NULL | NULL | 用户名快照 |
| `user_avatar` | VARCHAR(255) | NULL | NULL | 用户头像快照 |
| `parent_id` | INT | NULL | NULL | 父评论ID（用于回复） |
| `root_id` | INT | NULL | NULL | 根评论ID（用于评论树） |
| `content` | TEXT | NOT NULL | - | 讨论内容 |
| `like_count` | INT | NULL | NULL | 点赞数 |
| `reply_count` | INT | NULL | NULL | 回复数 |
| `status` | ENUM | NULL | NULL | 状态：APPROVED-已通过，PENDING-待审核，REJECTED-已拒绝 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `product_id` → `products(id)`
- 外键索引: `user_id` → `users(id)`
- 建议索引: `product_id` + `status` + `created_at`（商品讨论列表查询）
- 建议索引: `parent_id`（回复查询）
- 建议索引: `root_id`（评论树查询）
- 建议索引: `status`（讨论审核查询）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
```

---

### 8. addresses - 用户收货地址表

存储用户的收货地址信息，支持设置默认地址。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 地址ID |
| `user_id` | INT | FOREIGN KEY, NOT NULL | - | 用户ID |
| `receiver_name` | VARCHAR(50) | NOT NULL | - | 收货人姓名 |
| `receiver_phone` | VARCHAR(20) | NOT NULL | - | 收货人电话 |
| `province` | VARCHAR(50) | NULL | NULL | 省份 |
| `city` | VARCHAR(50) | NULL | NULL | 城市 |
| `district` | VARCHAR(50) | NULL | NULL | 区/县 |
| `detail_address` | VARCHAR(255) | NOT NULL | - | 详细地址 |
| `is_default` | BOOLEAN | NULL | FALSE | 是否默认地址 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `user_id` → `users(id)`
- 建议索引: `user_id` + `is_default`（用户默认地址查询）

**外键约束**:
```sql
FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
```

---

### 9. product_snapshots - 商品快照表

保存下单时的商品信息快照，确保订单历史数据不受商品信息变更影响。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 快照ID |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 原商品ID |
| `title` | VARCHAR(100) | NOT NULL | - | 商品名称快照 |
| `category` | VARCHAR(50) | NULL | NULL | 分类快照 |
| `cover_url` | VARCHAR(255) | NULL | NULL | 封面图快照 |
| `price` | DECIMAL(10,2) | NOT NULL | - | 价格快照 |
| `merchant_id` | INT | NULL | NULL | 商家ID快照 |
| `merchant_name` | VARCHAR(50) | NULL | NULL | 商家名称快照 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `product_id` → `products(id)`
- 建议索引: `created_at`（快照时间查询）

---

### 10. orders - 订单表

存储订单的基本信息，支持多种订单状态和商家确认模式。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 订单ID |
| `order_no` | VARCHAR(32) | NOT NULL, UNIQUE | - | 订单号 |
| `user_id` | INT | FOREIGN KEY, NOT NULL | - | 用户ID |
| `address_id` | INT | FOREIGN KEY | NULL | 收货地址ID |
| `total_amount` | DECIMAL(10,2) | NOT NULL | - | 订单总金额 |
| `item_count` | INT | NULL | 0 | 商品种类数 |
| `status` | ENUM | NOT NULL | 'PENDING_CONFIRMATION' | 订单状态：PENDING_CONFIRMATION-待确认，CONFIRMED-已确认，REJECTED-已拒绝，PENDING_PAYMENT-待付款，PAID-已付款，SHIPPED-已发货，DELIVERED-已送达，COMPLETED-已完成，CANCELLED-已取消，REFUNDED-已退款 |
| `pay_expire_at` | TIMESTAMP | NULL | NULL | 支付过期时间 |
| `receiver_name` | VARCHAR(50) | NULL | NULL | 收货人姓名 |
| `receiver_phone` | VARCHAR(20) | NULL | NULL | 收货人电话 |
| `receiver_address` | VARCHAR(255) | NULL | NULL | 收货地址 |
| `remark` | VARCHAR(500) | NULL | NULL | 订单备注 |
| `paid_at` | TIMESTAMP | NULL | NULL | 支付时间 |
| `confirmed_at` | TIMESTAMP | NULL | NULL | 确认时间 |
| `rejected_at` | TIMESTAMP | NULL | NULL | 拒绝时间 |
| `reject_reason` | VARCHAR(255) | NULL | NULL | 拒绝原因 |
| `auto_confirmed` | BOOLEAN | NULL | FALSE | 是否自动确认 |
| `shipped_at` | TIMESTAMP | NULL | NULL | 发货时间 |
| `completed_at` | TIMESTAMP | NULL | NULL | 完成时间 |
| `cancelled_at` | TIMESTAMP | NULL | NULL | 取消时间 |
| `cancel_reason` | VARCHAR(255) | NULL | NULL | 取消原因 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `order_no`
- 外键索引: `user_id` → `users(id)`
- 外键索引: `address_id` → `addresses(id)`
- 建议索引: `user_id` + `status` + `created_at`（用户订单列表查询）
- 建议索引: `status` + `created_at`（订单状态查询）
- 建议索引: `created_at`（订单时间查询）

**外键约束**:
```sql
FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
FOREIGN KEY (`address_id`) REFERENCES `addresses`(`id`) ON DELETE SET NULL
```

---

### 11. order_items - 订单项表

存储订单中的商品明细，支持一个订单包含多个商品。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 订单项ID |
| `order_id` | INT | FOREIGN KEY, NOT NULL | - | 订单ID |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品ID |
| `snapshot_id` | BIGINT | FOREIGN KEY, NOT NULL | - | 商品快照ID |
| `quantity` | INT | NOT NULL | - | 购买数量 |
| `unit_price` | DECIMAL(10,2) | NOT NULL | - | 单价（快照价格） |
| `total_price` | DECIMAL(10,2) | NOT NULL | - | 小计金额 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `order_id` → `orders(id)`
- 外键索引: `product_id` → `products(id)`
- 外键索引: `snapshot_id` → `product_snapshots(id)`
- 建议索引: `order_id`（订单明细查询）
- 建议索引: `product_id`（商品订单查询）

**外键约束**:
```sql
FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE
FOREIGN KEY (`snapshot_id`) REFERENCES `product_snapshots`(`id`)
```

---

### 12. stock_reservations - 库存预占记录表

记录订单创建时的库存预占信息，防止超卖。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 预占ID |
| `order_no` | VARCHAR(32) | NOT NULL | - | 订单号 |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品ID |
| `quantity` | INT | NOT NULL | - | 预占数量 |
| `status` | ENUM | NOT NULL | 'RESERVED' | 状态：RESERVED-已预占，CONFIRMED-已确认，RELEASED-已释放 |
| `expire_at` | TIMESTAMP | NOT NULL | - | 过期时间 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `order_no` + `product_id`
- 外键索引: `product_id` → `products(id)`
- 建议索引: `expire_at`（过期预占清理）
- 建议索引: `status`（状态查询）

**外键约束**:
```sql
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
```

---

### 13. payments - 支付记录表

存储订单的支付信息，支持多种支付方式。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 支付ID |
| `order_no` | VARCHAR(32) | NOT NULL, UNIQUE | - | 订单号 |
| `pay_no` | VARCHAR(64) | NULL | NULL | 支付流水号 |
| `amount` | DECIMAL(10,2) | NOT NULL | - | 支付金额 |
| `pay_method` | ENUM | NULL | NULL | 支付方式：ALIPAY-支付宝，WECHAT-微信支付，BALANCE-余额支付 |
| `status` | ENUM | NOT NULL | 'PENDING' | 支付状态：PENDING-待支付，SUCCESS-支付成功，FAILED-支付失败，REFUNDED-已退款 |
| `paid_at` | TIMESTAMP | NULL | NULL | 支付时间 |
| `notify_data` | TEXT | NULL | NULL | 支付回调数据 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `order_no`
- 建议索引: `pay_no`（支付流水号查询）
- 建议索引: `status`（支付状态查询）

---

### 14. browsing_history - 浏览记录表

记录用户的商品浏览历史，用于个性化推荐和浏览记录查询。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | - | 浏览记录ID |
| `user_id` | INT | FOREIGN KEY, NOT NULL | - | 用户ID |
| `product_id` | INT | FOREIGN KEY, NOT NULL | - | 商品ID |
| `viewed_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 浏览时间 |

**索引**:
- 主键索引: `id`
- 外键索引: `user_id` → `users(id)`
- 外键索引: `product_id` → `products(id)`
- 建议索引: `user_id` + `viewed_at`（用户浏览记录查询）

**外键约束**:
```sql
FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
```

---

### 15. logistics_info - 物流信息表

存储订单的物流配送信息，支持多家物流公司和菜鸟网络集成。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 物流信息ID |
| `order_no` | VARCHAR(32) | NOT NULL, UNIQUE | - | 订单号 |
| `logistics_company` | ENUM | NOT NULL | - | 物流公司：TEST-测试，SF-顺丰，STO-申通，YTO-圆通，ZTO-中通，EMS-EMS |
| `tracking_no` | VARCHAR(50) | NOT NULL | - | 物流单号 |
| `waybill_url` | VARCHAR(255) | NULL | NULL | 面单URL |
| `status` | ENUM | NOT NULL | 'CREATED' | 物流状态：CREATED-已创建，PICKED-已揽收，IN_TRANSIT-运输中，DELIVERED-已送达，EXCEPTION-异常 |
| `estimated_delivery` | TIMESTAMP | NULL | NULL | 预计送达时间 |
| `delivered_at` | TIMESTAMP | NULL | NULL | 实际送达时间 |
| `trace_info` | TEXT | NULL | NULL | 物流轨迹信息（JSON格式） |
| `cainiao_subscribed` | BOOLEAN | NULL | FALSE | 是否订阅菜鸟网络 |
| `cainiao_last_update` | TIMESTAMP | NULL | NULL | 菜鸟网络最后更新时间 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `order_no`
- 建议索引: `tracking_no`（物流单号查询）
- 建议索引: `status`（物流状态查询）

---

### 16. operation_logs - 操作日志表

记录系统中的操作日志，用于审计和问题追踪。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 日志ID |
| `user_id` | INT | NULL | NULL | 用户ID |
| `username` | VARCHAR(50) | NULL | NULL | 用户名 |
| `module` | VARCHAR(50) | NULL | NULL | 模块名称 |
| `operation` | VARCHAR(50) | NULL | NULL | 操作类型 |
| `description` | VARCHAR(500) | NULL | NULL | 操作描述 |
| `request_method` | VARCHAR(10) | NULL | NULL | 请求方法（GET/POST/PUT/DELETE） |
| `request_url` | VARCHAR(255) | NULL | NULL | 请求URL |
| `request_params` | TEXT | NULL | NULL | 请求参数（JSON格式） |
| `response_data` | TEXT | NULL | NULL | 响应数据（JSON格式） |
| `ip_address` | VARCHAR(50) | NULL | NULL | 客户端IP地址 |
| `execute_time` | BIGINT | NULL | NULL | 执行时间（毫秒） |
| `status` | VARCHAR(20) | NULL | NULL | 操作状态 |
| `error_message` | TEXT | NULL | NULL | 错误信息 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |

**索引**:
- 主键索引: `id`
- 建议索引: `user_id`（用户操作日志查询）
- 建议索引: `module` + `operation`（模块操作查询）
- 建议索引: `created_at`（时间范围查询）
- 建议索引: `status`（状态查询）

---

### 17. risk_control_records - 风控记录表

存储订单的风控审核记录，用于风险控制和订单审核。

| 字段名 | 类型 | 约束 | 默认值 | 说明 |
|--------|------|------|--------|------|
| `id` | BIGINT | PRIMARY KEY, AUTO_INCREMENT | - | 风控记录ID |
| `order_no` | VARCHAR(32) | NOT NULL, UNIQUE | - | 订单号 |
| `user_id` | INT | NOT NULL | - | 用户ID |
| `rule_id` | VARCHAR(50) | NULL | NULL | 触发的风控规则ID |
| `risk_level` | ENUM | NOT NULL | - | 风险等级：LOW-低风险，MEDIUM-中风险，HIGH-高风险，CRITICAL-严重风险 |
| `status` | ENUM | NOT NULL | 'PENDING' | 审核状态：PENDING-待审核，APPROVED-已通过，REJECTED-已拒绝，MANUAL_REVIEW-人工复核 |
| `risk_score` | INT | NULL | NULL | 风险评分 |
| `risk_reason` | VARCHAR(500) | NULL | NULL | 风险原因 |
| `reviewer_id` | INT | NULL | NULL | 审核人ID |
| `review_comment` | VARCHAR(500) | NULL | NULL | 审核意见 |
| `reviewed_at` | TIMESTAMP | NULL | NULL | 审核时间 |
| `created_at` | TIMESTAMP | NULL | CURRENT_TIMESTAMP | 创建时间 |

**索引**:
- 主键索引: `id`
- 唯一索引: `order_no`
- 建议索引: `user_id`（用户风控记录查询）
- 建议索引: `risk_level`（风险等级查询）
- 建议索引: `status`（审核状态查询）

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
         │                       │
         │                       │ 1:N
         │                       │
         │              ┌─────────────────────────┐
         │              │ product_discussions    │
         │              ├─────────────────────────┤
         │              │ PK id                   │
         │              │ FK product_id           │
         │              │ FK user_id              │
         │              │    content              │
         │              │    like_count           │
         │              └─────────────────────────┘
         │                       │
         │                       │ 1:N
         │                       │
         │              ┌─────────────────────────┐
         │              │ product_snapshots       │
         │              ├─────────────────────────┤
         │              │ PK id                   │
         │              │ FK product_id           │
         │              │    title                │
         │              │    price                │
         │              └─────────────────────────┘
         │                       │
         │                       │ 1:N
         │                       │
         │              ┌─────────────────────────┐
         │              │    stock_reservations    │
         │              ├─────────────────────────┤
         │              │ PK id                   │
         │              │ FK product_id           │
         │              │    quantity             │
         │              │    status               │
         │              └─────────────────────────┘
         │
         │ 1:N
         │
         │  ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
         │  │    addresses    │         │     orders      │         │   order_items   │
         │  ├─────────────────┤         ├─────────────────┤         ├─────────────────┤
         │  │ PK id           │◄────────┤ FK user_id      │◄────────┤ FK order_id     │
         │  │ FK user_id      │   1:N   │    order_no     │   1:N   │ FK product_id   │
         │  │    receiver     │         │    total_amount │         │ FK snapshot_id  │
         │  └─────────────────┘         │    status       │         │    quantity     │
         │                              └─────────────────┘         └─────────────────┘
         │                                       │
         │                                       │ 1:1
         │                                       │
         │                              ┌─────────────────┐
         │                              │    payments     │
         │                              ├─────────────────┤
         │                              │ PK id           │
         │                              │    order_no     │
         │                              │    amount       │
         │                              │    status       │
         │                              └─────────────────┘
         │                                       │
         │                                       │ 1:1
         │                                       │
         │                              ┌─────────────────┐
         │                              │  logistics_info │
         │                              ├─────────────────┤
         │                              │ PK id           │
         │                              │    order_no     │
         │                              │    tracking_no  │
         │                              │    status       │
         │                              └─────────────────┘
         │                                       │
         │                                       │ 1:1
         │                                       │
         │                              ┌─────────────────┐
         │                              │risk_control_rec │
         │                              ├─────────────────┤
         │                              │ PK id           │
         │                              │    order_no     │
         │                              │    risk_level   │
         │                              │    status       │
         │                              └─────────────────┘
         │
         │ 1:N
         │
         │  ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
         │  │ browsing_history│         │  operation_logs │         │                 │
         │  ├─────────────────┤         ├─────────────────┤         │                 │
         │  │ PK id           │         │ PK id           │         │                 │
         │  │ FK user_id      │         │    user_id      │         │                 │
         │  │ FK product_id   │         │    module       │         │                 │
         │  │    viewed_at    │         │    operation    │         │                 │
         │  └─────────────────┘         └─────────────────┘         │                 │
         │                                                            │                 │
         └────────────────────────────────────────────────────────────┘                 │
                                                                               │         │
                                                                               └─────────┘
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
| products | product_discussions | 1:N | products.id = product_discussions.product_id | ON DELETE CASCADE |
| products | product_snapshots | 1:N | products.id = product_snapshots.product_id | - |
| products | stock_reservations | 1:N | products.id = stock_reservations.product_id | - |
| users | product_reviews | 1:N | users.id = product_reviews.user_id | ON DELETE CASCADE |
| users | product_discussions | 1:N | users.id = product_discussions.user_id | ON DELETE SET NULL |
| users | addresses | 1:N | users.id = addresses.user_id | ON DELETE CASCADE |
| users | orders | 1:N | users.id = orders.user_id | ON DELETE CASCADE |
| addresses | orders | 1:N | addresses.id = orders.address_id | ON DELETE SET NULL |
| orders | order_items | 1:N | orders.id = order_items.order_id | ON DELETE CASCADE |
| product_snapshots | order_items | 1:N | product_snapshots.id = order_items.snapshot_id | - |
| orders | payments | 1:1 | orders.order_no = payments.order_no | - |
| orders | logistics_info | 1:1 | orders.order_no = logistics_info.order_no | - |
| orders | risk_control_records | 1:1 | orders.order_no = risk_control_records.order_no | - |
| users | browsing_history | 1:N | users.id = browsing_history.user_id | ON DELETE CASCADE |
| products | browsing_history | 1:N | products.id = browsing_history.product_id | ON DELETE CASCADE |
| users | operation_logs | 1:N | users.id = operation_logs.user_id | - |
| users | risk_control_records | 1:N | users.id = risk_control_records.user_id | - |

---



*文档版本：4.0*
*最后更新：2026-03-12*
*更新内容：新增 browsing_history（浏览记录表）、logistics_info（物流信息表）、operation_logs（操作日志表）、risk_control_records（风控记录表）四个表结构；更新 products 表字段，新增 features、description_content、need_regenerate_tags 字段；更新 ER 关系图和关系说明以包含新增表*
