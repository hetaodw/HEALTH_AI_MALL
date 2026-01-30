# Health Mall 后端 API 文档

## 目录

- [服务端口信息](#服务端口信息)
- [通用响应格式](#通用响应格式)
- [认证相关 API](#认证相关-api)
  - [1. 用户注册](#1-用户注册)
  - [2. 用户登录](#2-用户登录)
  - [3. 用户登出](#3-用户登出)
- [用户相关 API](#用户相关-api)
  - [4. 获取用户信息](#4-获取用户信息)
  - [5. 更新用户信息](#5-更新用户信息)
- [商品相关 API (用户端)](#商品相关-api-用户端)
  - [6. 获取商品列表](#6-获取商品列表)
  - [7. 搜索商品](#7-搜索商品)
  - [8. 获取热门商品](#8-获取热门商品)
  - [9. 获取商品详情](#9-获取商品详情)
  - [10. 按分类获取商品](#10-按分类获取商品)
- [文件上传 API](#文件上传-api)
  - [11. 上传图片](#11-上传图片)
- [商家商品管理 API](#商家商品管理-api)
  - [12. 添加商品](#12-添加商品)
  - [13. 更新商品](#13-更新商品)
  - [14. 删除商品](#14-删除商品)
  - [15. 获取商家商品列表](#15-获取商家商品列表)
  - [16. 获取商家商品详情](#16-获取商家商品详情)
  - [17. 更新商品状态](#17-更新商品状态)
  - [18. 更新商品库存](#18-更新商品库存)
- [管理员 API](#管理员-api)
  - [19. 创建商品 (管理员)](#19-创建商品-管理员)
  - [20. 删除商品 (管理员)](#20-删除商品-管理员)
- [订单 API](#订单-api)
  - [21. 创建订单](#21-创建订单)
  - [22. 查询我的订单列表](#22-查询我的订单列表)
  - [23. 查询订单详情](#23-查询订单详情)
  - [24. 取消订单](#24-取消订单)
- [测试用例 (cURL)](#测试用例-curl)
- [状态码说明](#状态码说明)
- [角色说明](#角色说明)

---

## 服务端口信息

| 服务 | 容器端口 | 映射端口 | 说明 |
|------|----------|----------|------|
| mall-backend | 8080 | 8080 | 后端API服务 |
| mall-mysql | 3306 | 4000 | MySQL数据库 |
| mall-redis | 6379 | 6379 | Redis缓存 |
| mall-nginx | 80 | 80 | Nginx反向代理 |
| mall-frontend | 80 | 3000 | 前端服务 |

**API 基础路径**: `http://localhost:8080/v1`

---

## 通用响应格式

所有API响应均使用统一格式：

```json
{
  "code": 200,      // 状态码: 200成功, 401未授权, 500服务器错误
  "msg": "操作成功", // 提示信息
  "data": {}        // 响应数据
}
```

### 分页响应格式

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [],     // 数据列表
    "total": 100    // 总记录数
  }
}
```

---

## 认证相关 API

### 1. 用户注册

**接口**: `POST /v1/auth/register`

**请求体**:
```json
{
  "username": "zhangsan",
  "password": "123456",
  "avatarUrl": "http://example.com/avatar.jpg",
  "email": "zhangsan@example.com",
  "phone": "13800138000",
  "role": "USER",
  "remarks": "用户备注"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |
| avatarUrl | string | 否 | 头像URL |
| email | string | 否 | 邮箱 |
| phone | string | 否 | 手机号 |
| role | string | 否 | 角色: USER/ADMIN/MERCHANT |
| remarks | string | 否 | 备注 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 2. 用户登录

**接口**: `POST /v1/auth/login`

**请求体**:
```json
{
  "username": "zhangsan",
  "password": "123456"
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "userInfo": {
      "id": 1,
      "username": "zhangsan",
      "avatarUrl": "http://example.com/avatar.jpg",
      "email": "zhangsan@example.com",
      "phone": "13800138000",
      "role": "USER"
    }
  }
}
```

---

### 3. 用户登出

**接口**: `POST /v1/auth/logout`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 用户相关 API

### 4. 获取用户信息

**接口**: `GET /v1/user/profile`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "username": "zhangsan",
    "avatarUrl": "http://example.com/avatar.jpg",
    "email": "zhangsan@example.com",
    "phone": "13800138000",
    "role": "USER",
    "remarks": "用户备注",
    "createdAt": "2024-01-15 10:30:00"
  }
}
```

---

### 5. 更新用户信息

**接口**: `PUT /v1/user/profile/update`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| avatarUrl | string | 否 | 头像URL |
| remarks | string | 否 | 备注 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 商品相关 API (用户端)

### 6. 获取商品列表

**接口**: `GET /v1/products`

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |
| isHot | boolean | 否 | - | 是否热门 |
| category | string | 否 | - | 分类 |
| minPrice | decimal | 否 | - | 最低价格 |
| maxPrice | decimal | 否 | - | 最高价格 |
| sortBy | string | 否 | - | 排序字段 |
| sortOrder | string | 否 | - | 排序方式: asc/desc |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "维生素C片",
        "coverUrl": "http://example.com/product1.jpg",
        "price": 59.90,
        "stock": 100,
        "category": "保健品",
        "isHot": true
      }
    ],
    "total": 50
  }
}
```

---

### 7. 搜索商品

**接口**: `GET /v1/products/search`

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| keyword | string | 否 | - | 搜索关键词 |
| minPrice | decimal | 否 | - | 最低价格 |
| maxPrice | decimal | 否 | - | 最高价格 |
| sortBy | string | 否 | - | 排序字段 |
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |

**响应示例**: 同商品列表

---

### 8. 获取热门商品

**接口**: `GET /v1/products/hot`

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| limit | int | 否 | 10 | 返回数量 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 1,
      "title": "维生素C片",
      "coverUrl": "http://example.com/product1.jpg",
      "price": 59.90,
      "stock": 100,
      "category": "保健品",
      "isHot": true
    }
  ]
}
```

---

### 9. 获取商品详情

**接口**: `GET /v1/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**说明**: 此接口公开访问，无需登录。返回完整的商品信息，包括商家信息、商品详情和详细介绍图片列表。

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "merchantId": 3,
    "merchantName": "健康商城",
    "title": "天然维C片500mg",
    "category": "保健品",
    "description": "富含维生素C，增强免疫力，抗氧化",
    "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
    "features": "{\"brand\":\"健康品牌\",\"specification\":\"500mg/片\",\"origin\":\"中国\"}",
    "price": 999.00,
    "stock": 99,
    "sales": 0,
    "status": "ON_SALE",
    "createdAt": "2026-01-30T01:03:40",
    "detailImages": [
      "http://localhost:8080/v1/static/product/detail/2026/01/30/detail1.jpg",
      "http://localhost:8080/v1/static/product/detail/2026/01/30/detail2.jpg",
      "http://localhost:8080/v1/static/product/detail/2026/01/30/detail3.jpg"
    ]
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |
| merchantId | int | 商家ID |
| merchantName | string | 商家名称 |
| title | string | 商品标题 |
| category | string | 商品分类 |
| description | string | 商品描述 |
| coverUrl | string | 封面图片URL |
| features | string | 商品特性（JSON格式字符串） |
| price | decimal | 价格 |
| stock | int | 库存数量 |
| sales | int | 销量 |
| status | string | 商品状态: ON_SALE(在售), OFF_SALE(下架), OUT_OF_STOCK(缺货) |
| createdAt | datetime | 创建时间 |
| detailImages | array | 详细介绍图片URL列表 |

---

### 10. 按分类获取商品

**接口**: `GET /v1/products/category/{category}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 商品分类 |

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |

**响应示例**: 同商品列表

---

## 文件上传 API

### 11. 上传图片

**接口**: `POST /v1/upload/image`

**请求头**: 
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 图片文件 |
| type | string | 否 | 上传类型，默认uploads |

**响应示例**:
```json
{
  "code": 200,
  "msg": "上传成功",
  "data": {
    "url": "http://localhost:8080/uploads/20240115/abc123.jpg"
  }
}
```

---

## 商家商品管理 API

### 12. 添加商品

**接口**: `POST /v1/merchant/products`

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**请求体**:
```json
{
  "title": "维生素C片",
  "category": "保健品",
  "description": "提高免疫力",
  "coverUrl": "http://example.com/cover.jpg",
  "features": "天然提取",
  "price": 59.90,
  "stock": 100,
  "status": "ACTIVE"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 商品标题 |
| category | string | 是 | 商品分类 |
| description | string | 否 | 商品描述 |
| coverUrl | string | 否 | 封面图URL |
| features | string | 否 | 商品特点 |
| price | decimal | 是 | 价格 |
| stock | int | 是 | 库存 |
| status | string | 否 | 状态: ACTIVE/INACTIVE/PENDING |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "title": "维生素C片",
    "category": "保健品",
    "price": 59.90,
    "stock": 100,
    "status": "ACTIVE",
    "createdAt": "2024-01-15 10:30:00"
  }
}
```

---

### 13. 更新商品

**接口**: `PUT /v1/merchant/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**请求体**: 同添加商品

**响应示例**: 同添加商品响应

---

### 14. 删除商品

**接口**: `DELETE /v1/merchant/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 15. 获取商家商品列表

**接口**: `GET /v1/merchant/products`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |
| status | string | 否 | - | 状态筛选 |
| category | string | 否 | - | 分类筛选 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "维生素C片",
        "category": "保健品",
        "price": 59.90,
        "stock": 100,
        "status": "ACTIVE",
        "createdAt": "2024-01-15 10:30:00"
      }
    ],
    "total": 20
  }
}
```

---

### 16. 获取商家商品详情

**接口**: `GET /v1/merchant/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同添加商品响应

---

### 17. 更新商品状态

**接口**: `PATCH /v1/merchant/products/{id}/status`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 是 | 状态: ACTIVE/INACTIVE/PENDING |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 18. 更新商品库存

**接口**: `PATCH /v1/merchant/products/{id}/stock`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| stock | int | 是 | 库存数量 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 管理员 API

### 19. 创建商品 (管理员)

**接口**: `POST /v1/admin/products`

**请求头**: `Authorization: Bearer {token}` (需要ADMIN角色)

**请求体**:
```json
{
  "name": "维生素C片",
  "category": "保健品",
  "price": 59.90,
  "stock": 100,
  "description": "提高免疫力",
  "coverUrl": "http://example.com/cover.jpg",
  "features": "天然提取"
}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": 1
}
```

---

### 20. 删除商品 (管理员)

**接口**: `DELETE /v1/admin/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 测试用例 (cURL)

### 1. 用户注册
```bash
curl -X POST http://localhost:8080/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "123456",
    "email": "test@example.com",
    "phone": "13800138000",
    "role": "USER"
  }'
```

### 2. 用户登录
```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "123456"
  }'
```

### 3. 获取用户信息
```bash
curl -X GET http://localhost:8080/v1/user/profile \
  -H "Authorization: Bearer {your_token}"
```

### 4. 获取商品列表
```bash
curl -X GET "http://localhost:8080/v1/products?page=1&size=10&category=保健品"
```

### 5. 搜索商品
```bash
curl -X GET "http://localhost:8080/v1/products/search?keyword=维生素&minPrice=10&maxPrice=100"
```

### 6. 获取商品详情
```bash
curl -X GET http://localhost:8080/v1/products/1
```

### 7. 上传图片
```bash
curl -X POST http://localhost:8080/v1/upload/image \
  -H "Authorization: Bearer {your_token}" \
  -F "file=@/path/to/image.jpg" \
  -F "type=products"
```

### 8. 商家添加商品
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "蛋白粉",
    "category": "健身补剂",
    "description": "增肌必备",
    "price": 199.00,
    "stock": 50,
    "status": "ACTIVE"
  }'
```

### 9. 商家更新商品状态
```bash
curl -X PATCH "http://localhost:8080/v1/merchant/products/1/status?status=INACTIVE" \
  -H "Authorization: Bearer {merchant_token}"
```

### 10. 商家更新商品库存
```bash
curl -X PATCH "http://localhost:8080/v1/merchant/products/1/stock?stock=200" \
  -H "Authorization: Bearer {merchant_token}"
```

---

## 订单 API

### 21. 创建订单

**接口**: `POST /v1/orders`

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "productId": 1,
  "quantity": 2,
  "receiverName": "张三",
  "receiverPhone": "13800138000",
  "receiverAddress": "北京市朝阳区xxx街道xxx号",
  "remark": "请尽快发货"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| productId | int | 是 | 商品ID |
| quantity | int | 是 | 购买数量 |
| receiverName | string | 是 | 收货人姓名 |
| receiverPhone | string | 是 | 收货人电话 |
| receiverAddress | string | 是 | 收货地址 |
| remark | string | 否 | 订单备注 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "202601300227557694",
    "userId": 4,
    "productId": 1,
    "productTitle": "维生素C片",
    "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
    "quantity": 2,
    "unitPrice": 999.00,
    "totalAmount": 1998.00,
    "status": "PENDING_PAYMENT",
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "receiverAddress": "北京市朝阳区xxx街道xxx号",
    "remark": "请尽快发货",
    "paidAt": null,
    "shippedAt": null,
    "completedAt": null,
    "createdAt": "2026-01-30T02:27:55"
  }
}
```

**订单状态说明**:
| 状态 | 说明 |
|------|------|
| PENDING_PAYMENT | 待付款 |
| PAID | 已付款 |
| SHIPPED | 已发货 |
| DELIVERED | 已送达 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |
| REFUNDED | 已退款 |

---

### 22. 查询我的订单列表

**接口**: `GET /v1/orders/my`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 1,
      "orderNo": "202601300227557694",
      "productTitle": "维生素C片",
      "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
      "quantity": 2,
      "totalAmount": 1998.00,
      "status": "PENDING_PAYMENT",
      "createdAt": "2026-01-30T02:27:55"
    }
  ]
}
```

---

### 23. 查询订单详情

**接口**: `GET /v1/orders/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 订单ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同创建订单响应

---

### 24. 取消订单

**接口**: `POST /v1/orders/{id}/cancel`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 订单ID |

**请求头**: `Authorization: Bearer {token}`

**说明**: 只能取消状态为"待付款"的订单，取消后恢复商品库存

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 测试用例 - 订单相关 (cURL)

### 11. 创建订单
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": 1,
    "quantity": 2,
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "receiverAddress": "北京市朝阳区xxx街道xxx号",
    "remark": "请尽快发货"
  }'
```

### 12. 查询我的订单
```bash
curl -X GET http://localhost:8080/v1/orders/my \
  -H "Authorization: Bearer {user_token}"
```

### 13. 查询订单详情
```bash
curl -X GET http://localhost:8080/v1/orders/1 \
  -H "Authorization: Bearer {user_token}"
```

### 14. 取消订单
```bash
curl -X POST http://localhost:8080/v1/orders/1/cancel \
  -H "Authorization: Bearer {user_token}"
```

---

## 状态码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 401 | 未授权，需要登录 |
| 403 | 禁止访问，权限不足 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 角色说明

| 角色 | 权限 |
|------|------|
| USER | 普通用户，可浏览商品、管理个人信息 |
| MERCHANT | 商家，可管理自己的商品 |
| ADMIN | 管理员，可管理所有商品和用户 |
