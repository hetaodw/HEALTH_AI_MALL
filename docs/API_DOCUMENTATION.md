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
  - [6. 上传用户头像](#6-上传用户头像)
- [商品相关 API (用户端)](#商品相关-api-用户端)
  - [7. 获取商品列表](#7-获取商品列表)
  - [8. 搜索商品](#8-搜索商品)
  - [9. 获取热门商品](#9-获取热门商品)
  - [10. 获取商品详情](#10-获取商品详情)
  - [11. 按分类获取商品](#11-按分类获取商品)
- [文件上传 API](#文件上传-api)
  - [12. 上传图片](#12-上传图片)
- [商家商品管理 API](#商家商品管理-api)
  - [13. 添加商品](#13-添加商品)
  - [14. 更新商品](#14-更新商品)
  - [15. 删除商品](#15-删除商品)
  - [16. 获取商家商品列表](#16-获取商家商品列表)
  - [17. 获取商家商品详情](#17-获取商家商品详情)
  - [18. 更新商品状态](#18-更新商品状态)
  - [19. 更新商品库存](#19-更新商品库存)
  - [20. 批量更新自动确认模式](#20-批量更新自动确认模式)
- [商家订单管理 API](#商家订单管理-api)
  - [21. 获取待确认订单列表](#21-获取待确认订单列表)
  - [22. 获取商家订单列表](#22-获取商家订单列表)
  - [23. 确认订单](#23-确认订单)
  - [24. 拒绝订单](#24-拒绝订单)
- [管理员 API](#管理员-api)
  - [25. 创建商品 (管理员)](#25-创建商品-管理员)
  - [26. 删除商品 (管理员)](#26-删除商品-管理员)
- [订单 API](#订单-api)
  - [27. 创建订单](#27-创建订单)
  - [28. 查询我的订单列表](#28-查询我的订单列表)
  - [29. 查询订单详情](#29-查询订单详情)
  - [30. 取消订单](#30-取消订单)
  - [31. 支付订单](#31-支付订单)
- [地址管理 API](#地址管理-api)
  - [32. 获取用户地址列表](#32-获取用户地址列表)
  - [33. 获取默认地址](#33-获取默认地址)
  - [34. 获取地址详情](#34-获取地址详情)
  - [35. 创建地址](#35-创建地址)
  - [36. 更新地址](#36-更新地址)
  - [37. 删除地址](#37-删除地址)
  - [38. 设置默认地址](#38-设置默认地址)
- [商品详情介绍 API](#商品详情介绍-api)
  - [39. 获取商品详情介绍](#39-获取商品详情介绍)
  - [40. 创建或更新商品详情介绍](#40-创建或更新商品详情介绍)
  - [41. 删除商品详情介绍](#41-删除商品详情介绍)
- [商品评价 API](#商品评价-api)
  - [42. 获取商品评价列表](#42-获取商品评价列表)
  - [43. 获取评价详情](#43-获取评价详情)
  - [44. 创建商品评价](#44-创建商品评价)
  - [45. 删除商品评价](#45-删除商品评价)
- [浏览记录 API](#浏览记录-api)
  - [46. 获取浏览记录列表](#46-获取浏览记录列表)
  - [47. 添加浏览记录](#47-添加浏览记录)
  - [48. 删除浏览记录](#48-删除浏览记录)
  - [49. 清空浏览记录](#49-清空浏览记录)
- [商品标签 API](#商品标签-api)
  - [50. 为商品生成标签](#50-为商品生成标签)
  - [51. 批量生成商品标签](#51-批量生成商品标签)
  - [52. 获取商品标签](#52-获取商品标签)
  - [53. 手动更新商品标签](#53-手动更新商品标签)
  - [54. 获取热门标签](#54-获取热门标签)
  - [55. 按标签搜索商品](#55-按标签搜索商品)
- [测试用例 (cURL)](#测试用例-curl)
- [状态码说明](#状态码说明)
- [角色说明](#角色说明)

---

## 商品标签 API

### 39. 获取商品详情介绍

**接口**: `GET /v1/product/descriptions/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "productId": 1,
    "content": "这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。适合日常保健，增强身体抵抗力。",
    "createdAt": "2026-02-28T10:00:00",
    "updatedAt": "2026-02-28T10:00:00"
  }
}
```

---

### 40. 创建或更新商品详情介绍

**接口**: `POST /v1/product/descriptions/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "content": "商品详细文字介绍内容..."
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | 是 | 商品详细文字介绍内容 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "productId": 1,
    "content": "商品详细文字介绍内容...",
    "createdAt": "2026-02-28T10:00:00",
    "updatedAt": "2026-02-28T10:00:00"
  }
}
```

---

### 41. 删除商品详情介绍

**接口**: `DELETE /v1/product/descriptions/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

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

## 商品评价 API

### 42. 获取商品评价列表

**接口**: `GET /v1/product/reviews/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "productId": 1,
        "userId": 1,
        "username": "zhangsan",
        "userAvatar": "http://example.com/avatar.jpg",
        "rating": 5,
        "title": "非常好的产品",
        "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
        "isAnonymous": false,
        "status": "APPROVED",
        "createdAt": "2026-02-28T10:00:00"
      }
    ],
    "averageRating": 4.5,
    "reviewCount": 10,
    "page": 1,
    "size": 10
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| list | array | 评价列表 |
| averageRating | double | 平均评分 (0-5) |
| reviewCount | long | 评价总数 |
| page | int | 当前页码 |
| size | int | 每页数量 |

---

### 43. 获取评价详情

**接口**: `GET /v1/product/reviews/detail/{reviewId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| reviewId | int | 评价 ID |

**响应示例**: 同评价列表中的单条评价数据结构

---

### 44. 创建商品评价

**接口**: `POST /v1/product/reviews/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "rating": 5,
  "title": "非常好的产品",
  "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
  "isAnonymous": false
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rating | int | 是 | 评分 (1-5) |
| title | string | 否 | 评价标题 |
| content | string | 否 | 评价内容 |
| isAnonymous | boolean | 否 | 是否匿名，默认 false |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "productId": 1,
    "userId": 1,
    "username": "zhangsan",
    "userAvatar": "http://example.com/avatar.jpg",
    "rating": 5,
    "title": "非常好的产品",
    "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
    "isAnonymous": false,
    "status": "APPROVED",
    "createdAt": "2026-02-28T10:00:00"
  }
}
```

---

### 45. 删除商品评价

**接口**: `DELETE /v1/product/reviews/{reviewId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| reviewId | int | 评价 ID |

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

## 浏览记录 API

### 46. 获取浏览记录列表

**接口**: `GET /v1/browsing-history`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 20 | 每页数量 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "productId": 1,
        "productTitle": "维生素C片",
        "productCoverUrl": "http://example.com/product1.jpg",
        "productPrice": 59.90,
        "viewedAt": "2026-03-04T10:00:00"
      }
    ],
    "total": 50
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| list | array | 浏览记录列表 |
| list[].id | int | 浏览记录ID |
| list[].productId | int | 商品ID |
| list[].productTitle | string | 商品标题 |
| list[].productCoverUrl | string | 商品封面图URL |
| list[].productPrice | decimal | 商品价格 |
| list[].viewedAt | datetime | 浏览时间 |
| total | long | 总记录数 |

---

### 47. 添加浏览记录

**接口**: `POST /v1/browsing-history/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**说明**: 
- 用户访问商品详情页时自动调用此接口
- 每个用户最多保留100条浏览记录，超出自动删除最早的
- 如果商品已删除，浏览记录会自动级联删除

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 48. 删除浏览记录

**接口**: `DELETE /v1/browsing-history/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**说明**: 删除指定商品的浏览记录

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 49. 清空浏览记录

**接口**: `DELETE /v1/browsing-history`

**请求头**: `Authorization: Bearer {token}`

**说明**: 清空当前用户的所有浏览记录

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

## 商品标签 API

### 50. 为商品生成标签

**接口**: `POST /v1/products/tags/{productId}/generate`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**请求头**: `Authorization: Bearer {token}`

**说明**: 调用AI模型根据商品标题和介绍自动生成标签

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

---

### 51. 批量生成商品标签

**接口**: `POST /v1/products/tags/batch/generate`

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "productIds": [1, 2, 3, 4, 5]
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| productIds | array | 是 | 商品ID列表 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 4,
    "failedCount": 1,
    "failedProductIds": [5],
    "message": "批量生成完成：成功4个，失败1个"
  }
}
```

---

### 52. 获取商品标签

**接口**: `GET /v1/products/tags/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

---

### 53. 手动更新商品标签

**接口**: `PUT /v1/products/tags/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "tags": ["维生素", "增强免疫力", "抗氧化"]
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tags | array | 是 | 标签列表 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 54. 获取热门标签

**接口**: `GET /v1/products/tags/popular`

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| limit | int | 否 | 20 | 返回数量 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {"tag": "维生素", "count": 150},
    {"tag": "增强免疫力", "count": 120},
    {"tag": "抗氧化", "count": 98}
  ]
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| tag | string | 标签名称 |
| count | int | 使用该标签的商品数量 |

---

### 55. 按标签搜索商品

**接口**: `GET /v1/products/tags/search`

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| tags | array | 是 | - | 标签列表 |
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |

**请求示例**:
```
GET /v1/products/tags/search?tags=维生素&tags=增强免疫力&page=1&size=10
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://example.com/product1.jpg",
        "price": 59.90,
        "stock": 100,
        "tags": ["维生素", "增强免疫力", "抗氧化"]
      }
    ],
    "total": 50
  }
}
```

---

## 测试用例 - 商品标签 (cURL)

### 32. 为商品生成标签
```bash
curl -X POST http://localhost:8080/v1/products/tags/1/generate \
  -H "Authorization: Bearer {merchant_token}"
```

### 33. 批量生成商品标签
```bash
curl -X POST http://localhost:8080/v1/products/tags/batch/generate \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [1, 2, 3, 4, 5]
  }'
```

### 34. 获取商品标签
```bash
curl -X GET http://localhost:8080/v1/products/tags/1
```

### 35. 手动更新商品标签
```bash
curl -X PUT http://localhost:8080/v1/products/tags/1 \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "tags": ["维生素", "增强免疫力", "抗氧化"]
  }'
```

### 36. 获取热门标签
```bash
curl -X GET "http://localhost:8080/v1/products/tags/popular?limit=10"
```

### 37. 按标签搜索商品
```bash
curl -X GET "http://localhost:8080/v1/products/tags/search?tags=维生素&tags=增强免疫力&page=1&size=10"
```

---

## 测试用例 - 商品详情介绍和评价 (cURL)

### 22. 获取商品详情介绍
```bash
curl -X GET http://localhost:8080/v1/product/descriptions/1
```

### 23. 创建或更新商品详情介绍
```bash
curl -X POST http://localhost:8080/v1/product/descriptions/1 \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。"
  }'
```

### 24. 删除商品详情介绍
```bash
curl -X DELETE http://localhost:8080/v1/product/descriptions/1 \
  -H "Authorization: Bearer {merchant_token}"
```

### 25. 获取商品评价列表
```bash
curl -X GET "http://localhost:8080/v1/product/reviews/1?page=1&size=10"
```

### 26. 创建商品评价
```bash
curl -X POST http://localhost:8080/v1/product/reviews/1 \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "title": "非常好的产品",
    "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
    "isAnonymous": false
  }'
```

### 27. 删除商品评价
```bash
curl -X DELETE http://localhost:8080/v1/product/reviews/1 \
  -H "Authorization: Bearer {user_token}"
```

---

## 测试用例 - 浏览记录 (cURL)

### 28. 获取浏览记录列表
```bash
curl -X GET "http://localhost:8080/v1/browsing-history?page=1&size=20" \
  -H "Authorization: Bearer {user_token}"
```

### 29. 添加浏览记录
```bash
curl -X POST http://localhost:8080/v1/browsing-history/1 \
  -H "Authorization: Bearer {user_token}"
```

### 30. 删除单条浏览记录
```bash
curl -X DELETE http://localhost:8080/v1/browsing-history/1 \
  -H "Authorization: Bearer {user_token}"
```

### 31. 清空所有浏览记录
```bash
curl -X DELETE http://localhost:8080/v1/browsing-history \
  -H "Authorization: Bearer {user_token}"
```

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

### 6. 上传用户头像

**接口**: `POST /v1/user/avatar/upload`

**请求头**: 
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 头像图片文件 (JPG, PNG, GIF, 最大5MB) |

**响应示例**:
```json
{
  "code": 200,
  "msg": "头像上传成功",
  "data": {
    "avatarUrl": "http://localhost:8080/v1/static/user/avatar/2026/01/31/abc123.jpg"
  }
}
```

**说明**:
- 支持格式: JPG, JPEG, PNG, GIF
- 文件大小限制: 5MB
- 上传成功后自动更新用户头像URL
- 头像存储路径: `user/avatar/年/月/日/文件名`

---

## 商品相关 API (用户端)

### 7. 获取商品列表

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
        "category": "HEALTH_PRODUCTS",
        "isHot": true
      }
    ],
    "total": 50
  }
}
```

---

### 8. 搜索商品

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

### 9. 获取热门商品

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
      "category": "HEALTH_PRODUCTS",
      "isHot": true
    }
  ]
}
```

---

### 10. 获取商品详情

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
    "category": "HEALTH_PRODUCTS",
    "description": "富含维生素 C，增强免疫力，抗氧化",
    "descriptionContent": "这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。适合日常保健，增强身体抵抗力。",
    "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
    "features": "{\"brand\":\"健康品牌\",\"specification\":\"500mg/片\",\"origin\":\"中国\"}",
    "price": 999.00,
    "stock": 99,
    "sales": 0,
    "averageRating": 4.5,
    "reviewCount": 10,
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
| description | string | 商品简短描述 |
| descriptionContent | string | 商品详细文字介绍内容 |
| coverUrl | string | 封面图片 URL |
| features | string | 商品特性（JSON格式字符串） |
| price | decimal | 价格 |
| stock | int | 库存数量 |
| sales | int | 销量 |
| averageRating | double | 平均评分 (0-5) |
| reviewCount | int | 评价数量 |
| status | string | 商品状态：ON_SALE(在售), OFF_SALE(下架), OUT_OF_STOCK(缺货) |
| createdAt | datetime | 创建时间 |
| detailImages | array | 详细介绍图片URL列表 |

---

### 11. 按分类获取商品

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

### 12. 上传图片

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

### 13. 添加商品

**接口**: `POST /v1/merchant/products`

**请求头**: 
- `Authorization: Bearer {token}` (需要MERCHANT角色)
- `Content-Type: multipart/form-data`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 商品标题 |
| category | string | 是 | 商品分类 |
| description | string | 是 | 商品描述 |
| coverImage | file | 是 | 封面图片文件 |
| features | string | 否 | 商品特性（JSON格式字符串） |
| descriptionContent | string | 否 | 商品详细文字介绍内容 |
| price | decimal | 是 | 价格 |
| stock | int | 是 | 库存 |
| status | string | 否 | 状态: ON_SALE(在售)/OFF_SALE(下架)/OUT_OF_STOCK(缺货)，默认ON_SALE |
| autoConfirmMode | string | 否 | 自动确认模式: AUTO-自动确认, MANUAL-手动确认, SMART-智能确认（默认MANUAL） |
| autoConfirmCondition | string | 否 | 智能确认条件（JSON格式），仅在SMART模式下有效 |
| detailImages | file[] | 否 | 商品详情图片列表（可选） |

**商品分类枚举值**:
- HEALTH_PRODUCTS - 保健品
- MEDICAL_DEVICES - 医疗器械
- HEALTH_FOOD - 健康食品
- SPORTS_FITNESS - 运动健身
- MATERNAL_BABY - 母婴用品

**商品特性 (features) 格式示例**:
```json
{
  "brand": "品牌名称",
  "specification": "规格说明",
  "origin": "产地",
  "shelfLife": "保质期"
}
```

**请求示例 (cURL)**:
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {token}" \
  -F "title=维生素C片" \
  -F "category=HEALTH_PRODUCTS" \
  -F "description=提高免疫力" \
  -F "price=59.90" \
  -F "stock=100" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=MANUAL" \
  -F "features={\"brand\":\"健康品牌\",\"specification\":\"500mg/片\",\"origin\":\"中国\"}" \
  -F "coverImage=@/path/to/cover.jpg"
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "title": "维生素C片",
    "category": "HEALTH_PRODUCTS",
    "price": 59.90,
    "stock": 100,
    "status": "ON_SALE",
    "autoConfirmMode": "MANUAL",
    "autoConfirmCondition": null,
    "descriptionContent": "这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。",
    "createdAt": "2024-01-15 10:30:00"
  }
}
```

---

### 14. 更新商品

**接口**: `PUT /v1/merchant/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**请求参数**: 同添加商品（所有字段可选）

**字段说明**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 否 | 商品标题 |
| category | string | 否 | 商品分类 |
| description | string | 否 | 商品描述 |
| coverImage | file | 否 | 封面图片文件 |
| features | string | 否 | 商品特性（JSON格式字符串） |
| descriptionContent | string | 否 | 商品详细文字介绍内容 |
| price | decimal | 否 | 价格 |
| stock | int | 否 | 库存 |
| status | string | 否 | 状态: ON_SALE(在售)/OFF_SALE(下架)/OUT_OF_STOCK(缺货) |
| autoConfirmMode | string | 否 | 自动确认模式: AUTO-自动确认, MANUAL-手动确认, SMART-智能确认 |
| autoConfirmCondition | string | 否 | 智能确认条件（JSON格式），仅在SMART模式下有效 |
| detailImages | file[] | 否 | 商品详情图片列表 |

**响应示例**: 同添加商品响应

---

### 15. 删除商品

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

### 16. 获取商家商品列表

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
        "category": "HEALTH_PRODUCTS",
        "price": 59.90,
        "stock": 100,
        "status": "ON_SALE",
        "createdAt": "2024-01-15 10:30:00"
      }
    ],
    "total": 20
  }
}
```

---

### 17. 获取商家商品详情

**接口**: `GET /v1/merchant/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同添加商品响应

---

### 18. 更新商品状态

**接口**: `PATCH /v1/merchant/products/{id}/status`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品ID |

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 是 | 状态: ON_SALE(在售)/OFF_SALE(下架)/OUT_OF_STOCK(缺货) |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 19. 更新商品库存

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

### 20. 批量更新自动确认模式

**接口**: `PATCH /v1/merchant/products/auto-confirm-mode`

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**请求体**:
```json
{
  "productIds": [1, 2, 3],
  "autoConfirmMode": "AUTO"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| productIds | array | 是 | 商品ID列表 |
| autoConfirmMode | string | 是 | 自动确认模式: AUTO-自动确认, MANUAL-手动确认, SMART-智能确认 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 2,
    "failedCount": 1,
    "failedProducts": [
      {
        "productId": 3,
        "reason": "商品不存在"
      }
    ]
  }
}
```

**响应字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| successCount | int | 成功更新的商品数量 |
| failedCount | int | 更新失败的商品数量 |
| failedProducts | array | 失败的商品列表，包含商品ID和失败原因 |

---

## 商家订单管理 API

### 21. 获取待确认订单列表

**接口**: `GET /v1/merchant/orders/pending`

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**说明**: 获取当前商家所有状态为"待确认"的订单

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 1,
      "orderNo": "280686617910448128",
      "userId": 8,
      "totalAmount": 1998.00,
      "itemCount": 2,
      "status": "PENDING_CONFIRMATION",
      "receiverName": "张三",
      "receiverPhone": "13800138001",
      "receiverAddress": "北京市北京市朝阳区建国路88号",
      "remark": "请尽快发货",
      "createdAt": "2026-02-13T13:08:24.86944",
      "items": [
        {
          "id": 1,
          "productId": 1,
          "productTitle": "维生素C片",
          "productCoverUrl": "/v1/static/product/cover/2026/01/30/xxx.png",
          "category": "HEALTH_PRODUCTS",
          "merchantName": "MALL",
          "quantity": 2,
          "unitPrice": 999.00,
          "totalPrice": 1998.00
        }
      ]
    }
  ]
}
```

---

### 21. 获取商家订单列表

**接口**: `GET /v1/merchant/orders`

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 否 | 订单状态筛选，不传则返回所有订单 |

**说明**: 获取当前商家的所有订单

**响应示例**: 同获取待确认订单列表

---

### 22. 确认订单

**接口**: `POST /v1/merchant/orders/{orderId}/confirm`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderId | long | 订单ID |

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**说明**: 
- 只能确认状态为"待确认"的订单
- 确认前会检查库存是否充足
- 确认成功后订单状态变为"已确认"，用户可以进行支付
- 5分钟未确认的订单会自动确认（如果库存充足）

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "280686617910448128",
    "status": "CONFIRMED",
    "confirmedAt": "2026-02-13T13:15:00",
    "autoConfirmed": false,
    "items": [...]
  }
}
```

---

### 23. 拒绝订单

**接口**: `POST /v1/merchant/orders/{orderId}/reject`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderId | long | 订单ID |

**请求体**:
```json
{
  "rejectReason": "库存不足"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rejectReason | string | 是 | 拒绝原因 |

**请求头**: `Authorization: Bearer {token}` (需要MERCHANT角色)

**说明**: 
- 只能拒绝状态为"待确认"的订单
- 拒绝后会释放预占的库存
- 30分钟未处理的订单会自动拒绝

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "280686617910448128",
    "status": "REJECTED",
    "rejectedAt": "2026-02-13T13:15:00",
    "rejectReason": "库存不足",
    "items": [...]
  }
}
```

---

## 管理员 API

### 24. 创建商品 (管理员)

**接口**: `POST /v1/admin/products`

**请求头**: `Authorization: Bearer {token}` (需要ADMIN角色)

**请求体**:
```json
{
  "name": "维生素C片",
  "category": "HEALTH_PRODUCTS",
  "price": 59.90,
  "stock": 100,
  "description": "提高免疫力",
  "coverUrl": "http://example.com/cover.jpg",
  "features": "天然提取",
  "descriptionContent": "这款天然维 C 片采用优质原料，每片含有 500mg 维生素 C，能够有效增强免疫力，抗氧化，促进胶原蛋白合成。"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 商品名称 |
| category | string | 是 | 商品分类 |
| price | decimal | 是 | 价格 |
| stock | int | 是 | 库存 |
| description | string | 是 | 商品描述 |
| coverUrl | string | 否 | 封面图片URL |
| features | string | 否 | 商品特性（JSON格式字符串） |
| descriptionContent | string | 否 | 商品详细文字介绍内容 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": 1
}
```

---

### 25. 删除商品 (管理员)

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
curl -X GET "http://localhost:8080/v1/products?page=1&size=10&category=HEALTH_PRODUCTS"
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

### 8. 上传用户头像
```bash
curl -X POST http://localhost:8080/v1/user/avatar/upload \
  -H "Authorization: Bearer {user_token}" \
  -F "file=@/path/to/avatar.jpg"
```

### 9. 商家添加商品
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "蛋白粉",
    "category": "健身补剂",
    "description": "增肌必备",
    "descriptionContent": "这款蛋白粉采用优质乳清蛋白，每份含有25g蛋白质，能够有效促进肌肉生长和恢复。适合健身人群日常补充。",
    "price": 199.00,
    "stock": 50,
    "status": "ON_SALE"
  }'
```

### 10. 商家更新商品状态
```bash
curl -X PATCH "http://localhost:8080/v1/merchant/products/1/status?status=OFF_SALE" \
  -H "Authorization: Bearer {merchant_token}"
```

### 11. 商家更新商品库存
```bash
curl -X PATCH "http://localhost:8080/v1/merchant/products/1/stock?stock=200" \
  -H "Authorization: Bearer {merchant_token}"
```

---

## 订单 API

### 27. 创建订单

**接口**: `POST /v1/orders`

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "addressId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2
    },
    {
      "productId": 2,
      "quantity": 1
    }
  ],
  "remark": "请尽快发货"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| addressId | int | 是 | 收货地址ID |
| items | array | 是 | 订单商品列表 |
| items[].productId | int | 是 | 商品ID |
| items[].quantity | int | 是 | 购买数量 |
| remark | string | 否 | 订单备注 |

**订单自动确认规则**:
订单是否自动确认取决于订单中所有商品的 `autoConfirmMode` 设置：

1. **AUTO（自动确认）模式**：
   - 当商品库存充足时，订单自动确认
   - 库存不足时，订单需要商家手动确认

2. **MANUAL（手动确认）模式**：
   - 所有订单都需要商家手动确认
   - 订单状态为 `PENDING_CONFIRMATION`（待商家确认）

3. **SMART（智能确认）模式**：
   - 根据订单条件智能判断是否自动确认
   - 支持的条件包括：订单金额、用户评分、库存阈值等
   - 条件在商品的 `autoConfirmCondition` 字段中配置（JSON格式）

**订单状态说明**:
- `PENDING_CONFIRMATION`（待商家确认）：订单需要商家手动确认
- `PENDING_PAYMENT`（待付款）：订单已确认，等待用户付款

**说明**:
- 如果订单中任一商品为 `MANUAL` 模式，则整个订单需要商家手动确认
- 如果订单中所有商品为 `AUTO` 模式且库存充足，则订单自动确认
- `SMART` 模式的商品根据配置的条件判断是否自动确认
- 商家可以在添加或编辑商品时设置 `autoConfirmMode` 和 `autoConfirmCondition`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 2,
    "orderNo": "280686617910448128",
    "userId": 8,
    "totalAmount": 2064.00,
    "itemCount": 2,
    "status": "PENDING_PAYMENT",
    "autoConfirmed": true,
    "payExpireAt": "2026-02-13T13:23:24.865534",
    "receiverName": "张三",
    "receiverPhone": "13800138001",
    "receiverAddress": "北京市北京市朝阳区建国路88号SOHO现代城A座1001室",
    "remark": "请尽快发货",
    "paidAt": null,
    "shippedAt": null,
    "completedAt": null,
    "cancelledAt": null,
    "cancelReason": null,
    "createdAt": "2026-02-13T13:08:24.86944",
    "items": [
      {
        "id": 1,
        "productId": 1,
        "productTitle": "test",
        "productCoverUrl": "/v1/static/product/cover/2026/01/30/xxx.png",
        "category": "HEALTH_PRODUCTS",
        "merchantName": "MALL",
        "quantity": 2,
        "unitPrice": 999.00,
        "totalPrice": 1998.00
      },
      {
        "id": 2,
        "productId": 2,
        "productTitle": "测试商品",
        "productCoverUrl": "/v1/static/product/cover/2026/01/30/xxx.png",
        "category": "HEALTH_PRODUCTS",
        "merchantName": "MALL",
        "quantity": 1,
        "unitPrice": 66.00,
        "totalPrice": 66.00
      }
    ]
  }
}
```

**订单状态说明**:
| 状态 | 说明 |
|------|------|
| PENDING_CONFIRMATION | 待商家确认 |
| CONFIRMED | 商家已确认 |
| REJECTED | 商家已拒绝 |
| PENDING_PAYMENT | 待付款 |
| PAID | 已付款 |
| SHIPPED | 已发货 |
| DELIVERED | 已送达 |
| COMPLETED | 已完成 |
| CANCELLED | 已取消 |
| REFUNDED | 已退款 |

---

### 27. 查询我的订单列表

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

### 28. 查询订单详情

**接口**: `GET /v1/orders/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 订单ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同创建订单响应

---

### 29. 取消订单

**接口**: `POST /v1/orders/{id}/cancel`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 订单ID |

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| reason | string | 否 | 取消原因，默认"用户取消" |

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

### 30. 支付订单

**接口**: `POST /v1/orders/{orderNo}/pay`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| payMethod | string | 是 | 支付方式: ALIPAY(支付宝), WECHAT(微信), BANK(银行卡) |

**请求头**: `Authorization: Bearer {token}`

**说明**: 支付成功后订单状态变为"已付款"，库存预占转为正式扣减

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 2,
    "orderNo": "280686617910448128",
    "userId": 8,
    "totalAmount": 2064.00,
    "itemCount": 2,
    "status": "PAID",
    "paidAt": "2026-02-13T13:09:34.170749",
    "items": [...]
  }
}
```

---

## 测试用例 - 订单相关 (cURL)

### 11. 创建订单（多商品）
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {"productId": 1, "quantity": 2},
      {"productId": 2, "quantity": 1}
    ],
    "remark": "请尽快发货"
  }'
```

### 11.1 创建订单（自动确认）
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {"productId": 1, "quantity": 2},
      {"productId": 2, "quantity": 1}
    ],
    "remark": "请尽快发货",
    "autoConfirm": true
  }'
```
**说明**: 当设置 `autoConfirm: true` 且商品库存充足时，订单将自动跳过商家确认环节，直接进入待付款状态。

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

### 14. 支付订单
```bash
curl -X POST "http://localhost:8080/v1/orders/280686617910448128/pay?payMethod=ALIPAY" \
  -H "Authorization: Bearer {user_token}"
```

### 15. 取消订单
```bash
curl -X POST "http://localhost:8080/v1/orders/1/cancel?reason=不想要了" \
  -H "Authorization: Bearer {user_token}"
```

---

## 测试用例 - 商家订单管理 (cURL)

### 16. 获取待确认订单列表
```bash
curl -X GET http://localhost:8080/v1/merchant/orders/pending \
  -H "Authorization: Bearer {merchant_token}"
```

### 17. 获取商家订单列表
```bash
curl -X GET "http://localhost:8080/v1/merchant/orders?status=PENDING_CONFIRMATION" \
  -H "Authorization: Bearer {merchant_token}"
```

### 18. 确认订单
```bash
curl -X POST http://localhost:8080/v1/merchant/orders/1/confirm \
  -H "Authorization: Bearer {merchant_token}"
```

### 19. 拒绝订单
```bash
curl -X POST http://localhost:8080/v1/merchant/orders/1/reject \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "rejectReason": "库存不足"
  }'
```

---

## 地址管理 API

### 31. 获取用户地址列表

**接口**: `GET /v1/addresses`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 1,
      "userId": 8,
      "receiverName": "张三",
      "receiverPhone": "13800138001",
      "province": "北京市",
      "city": "北京市",
      "district": "朝阳区",
      "detailAddress": "建国路88号SOHO现代城A座1001室",
      "isDefault": true,
      "createdAt": "2026-02-13T13:03:22",
      "updatedAt": "2026-02-13T13:03:22",
      "fullAddress": "北京市北京市朝阳区建国路88号SOHO现代城A座1001室"
    }
  ]
}
```

---

### 32. 获取默认地址

**接口**: `GET /v1/addresses/default`

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同地址详情

---

### 33. 获取地址详情

**接口**: `GET /v1/addresses/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 地址ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "userId": 8,
    "receiverName": "张三",
    "receiverPhone": "13800138001",
    "province": "北京市",
    "city": "北京市",
    "district": "朝阳区",
    "detailAddress": "建国路88号SOHO现代城A座1001室",
    "isDefault": true,
    "createdAt": "2026-02-13T13:03:22",
    "updatedAt": "2026-02-13T13:03:22",
    "fullAddress": "北京市北京市朝阳区建国路88号SOHO现代城A座1001室"
  }
}
```

---

### 34. 创建地址

**接口**: `POST /v1/addresses`

**请求头**: `Authorization: Bearer {token}`

**请求体**:
```json
{
  "receiverName": "张三",
  "receiverPhone": "13800138001",
  "province": "北京市",
  "city": "北京市",
  "district": "朝阳区",
  "detailAddress": "建国路88号SOHO现代城A座1001室",
  "isDefault": true
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| receiverName | string | 是 | 收货人姓名 |
| receiverPhone | string | 是 | 收货人电话 |
| province | string | 是 | 省份 |
| city | string | 是 | 城市 |
| district | string | 是 | 区/县 |
| detailAddress | string | 是 | 详细地址 |
| isDefault | boolean | 否 | 是否默认地址，默认false |

**响应示例**: 同地址详情

---

### 35. 更新地址

**接口**: `PUT /v1/addresses/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 地址ID |

**请求头**: `Authorization: Bearer {token}`

**请求体**: 同创建地址

**响应示例**: 同地址详情

---

### 36. 删除地址

**接口**: `DELETE /v1/addresses/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 地址ID |

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

### 37. 设置默认地址

**接口**: `POST /v1/addresses/{id}/default`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 地址ID |

**请求头**: `Authorization: Bearer {token}`

**响应示例**: 同地址详情

---

## 测试用例 - 地址管理 (cURL)

### 28. 创建地址
```bash
curl -X POST http://localhost:8080/v1/addresses \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "receiverName": "张三",
    "receiverPhone": "13800138001",
    "province": "北京市",
    "city": "北京市",
    "district": "朝阳区",
    "detailAddress": "建国路88号SOHO现代城A座1001室",
    "isDefault": true
  }'
```

### 29. 获取地址列表
```bash
curl -X GET http://localhost:8080/v1/addresses \
  -H "Authorization: Bearer {user_token}"
```

### 30. 设置默认地址
```bash
curl -X POST http://localhost:8080/v1/addresses/1/default \
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

---

## 测试账号

以下账号用于 API 测试和开发调试：

### 用户账号

| 用户名 | 密码 | 角色 | 邮箱 | 手机号 |
|-------|------|------|------|--------|
| testuser1 | Test123456 | USER | testuser1@example.com | 13800138001 |
| testuser2 | Test123456 | USER | testuser2@example.com | 13800138002 |
| testuser3 | Test123456 | USER | testuser3@example.com | 13800138003 |

### 商家账号

| 用户名 | 密码 | 角色 | 邮箱 | 手机号 |
|-------|------|------|------|--------|
| testmerchant1 | Test123456 | MERCHANT | testmerchant1@example.com | 13800138004 |
| testmerchant2 | Test123456 | MERCHANT | testmerchant2@example.com | 13800138005 |

**注意**: 这些是测试账号，仅用于开发和测试环境。请勿在生产环境中使用。
