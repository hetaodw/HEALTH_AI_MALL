# Health Mall 后端 API 接口文档

## 1. 全局说明

**Base URL**: http://localhost/v1

**数据格式**: Content-Type: application/json

**通用响应结构**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**状态码说明**:
- 200: 请求成功
- 400: 参数错误
- 401: 未授权
- 500: 服务器内部错误

## 2. 用户认证模块

### 2.1 用户注册
- **接口地址**: `/auth/register`
- **请求方式**: POST
- **请求参数**:
  ```json
  {
    "username": "testuser",
    "password": "password123",
    "email": "test@example.com",
    "phone": "13800138000",
    "role": "USER",
    "avatar_url": "http://example.com/avatar.jpg",
    "remarks": "个人备注"
  }
  ```
- **参数说明**:
  - `username`: 用户名（必填）
  - `password`: 密码（必填）
  - `email`: 邮箱（必填）
  - `phone`: 手机号（必填）
  - `role`: 身份类型（可选，默认为USER）
    - `USER`: 普通用户
    - `MERCHANT`: 商家
  - `avatar_url`: 头像地址（可选）
  - `remarks`: 备注（可选）
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 2.2 用户登录
- **接口地址**: `/auth/login`
- **请求方式**: POST
- **请求参数**:
  ```json
  {
    "username": "testuser",
    "password": "password123"
  }
  ```
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "userInfo": {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "phone": "13800138000",
        "avatar_url": "http://example.com/avatar.jpg",
        "remarks": "个人备注"
      }
    }
  }
  ```

### 2.3 用户登出
- **接口地址**: `/auth/logout`
- **请求方式**: POST
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

## 3. 商品展示模块

**重要说明**: 所有商品查询接口都会自动过滤掉状态为 `OFF_SALE`（下架）的商品，仅展示 `ON_SALE`（在售）和 `OUT_OF_STOCK`（缺货）状态的商品。

### 3.1 获取商品列表
- **接口地址**: `/products`
- **请求方式**: GET
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
  - `isHot`: 是否只查询最热商品 (可选)
  - `category`: 商品分类 (可选，如：保健品、医疗器械、健康食品、运动健身、母婴用品)
  - `minPrice`: 最低价格 (可选)
  - `maxPrice`: 最高价格 (可选)
  - `sortBy`: 排序字段 (可选，如：price、stock、sales)
  - `sortOrder`: 排序方向 (可选，asc升序、desc降序)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "category": "保健品",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

### 3.2 搜索商品
- **接口地址**: `/products/search`
- **请求方式**: GET
- **查询参数**:
  - `keyword`: 搜索关键词 (匹配商品标题或描述)
  - `minPrice`: 最低价格
  - `maxPrice`: 最高价格
  - `sortBy`: 排序字段 (price_asc, price_desc, newest)
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

### 3.3 获取最热商品
- **接口地址**: `/products/hot`
- **请求方式**: GET
- **查询参数**:
  - `limit`: 返回数量 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://example.com/products/vitamin_c.jpg",
        "price": 98.00,
        "stock": 100
      }
    ]
  }
  ```

### 3.4 获取商品详情
- **接口地址**: `/products/{id}`
- **请求方式**: GET
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://example.com/products/vitamin_c.jpg",
      "features": {},
      "price": 98.00,
      "stock": 100,
      "detailImages": [
        "http://example.com/products/vitamin_c_detail1.jpg",
        "http://example.com/products/vitamin_c_detail2.jpg"
      ]
    }
  }
  ```

### 3.5 按分类获取商品
- **接口地址**: `/products/category/{category}`
- **请求方式**: GET
- **路径参数**:
  - `category`: 商品分类
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

## 4. 图片上传模块

### 4.1 上传商品图片
- **接口地址**: `/upload/image`
- **请求方式**: POST
- **请求头**: 需要携带token
- **请求类型**: multipart/form-data
- **请求参数**:
  - `file`: 图片文件（必填）
  - `type`: 图片类型（可选，用于区分不同用途的图片）
    - `avatar`: 用户头像
    - `product-cover`: 商品封面图
    - `product-detail`: 商品详情图
- **支持格式**: jpg, jpeg, png, gif
- **文件大小限制**: 最大5MB
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "上传成功",
    "data": {
      "url": "http://localhost/v1/static/product/cover/2025/12/30/abc123.jpg"
    }
  }
  ```

## 5. 商家商品管理模块

### 5.1 商家添加商品
- **接口地址**: `/merchant/products`
- **请求方式**: POST
- **请求头**: 需要携带token
- **请求参数**:
  ```json
  {
    "title": "天然维C片500mg",
    "category": "保健品",
    "description": "富含维生素C，增强免疫力，抗氧化",
    "coverUrl": "http://example.com/products/vitamin_c.jpg",
    "features": {},
    "price": 98.00,
    "stock": 100,
    "status": "ON_SALE"
  }
  ```
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://example.com/products/vitamin_c.jpg",
      "features": {},
      "price": 98.00,
      "stock": 100,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

### 5.2 商家修改商品
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: PUT
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **请求参数**:
  ```json
  {
    "title": "天然维C片500mg（升级版）",
    "category": "保健品",
    "description": "富含维生素C，增强免疫力，抗氧化，升级配方",
    "coverUrl": "http://example.com/products/vitamin_c_new.jpg",
    "features": {},
    "price": 108.00,
    "stock": 150,
    "status": "ON_SALE"
  }
  ```
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg（升级版）",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化，升级配方",
      "coverUrl": "http://example.com/products/vitamin_c_new.jpg",
      "features": {},
      "price": 108.00,
      "stock": 150,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

### 5.3 商家删除商品
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: DELETE
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 5.4 商家查询商品列表
- **接口地址**: `/merchant/products`
- **请求方式**: GET
- **请求头**: 需要携带token
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
  - `status`: 商品状态 (可选，ON_SALE/OFF_SALE/OUT_OF_STOCK)
  - `category`: 商品分类 (可选)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "category": "保健品",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100,
          "sales": 0,
          "status": "ON_SALE",
          "merchantId": 1
        }
      ],
      "total": 1
    }
  }
  ```

### 5.5 商家查询商品详情
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: GET
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://example.com/products/vitamin_c.jpg",
      "features": {},
      "price": 98.00,
      "stock": 100,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

### 5.6 商家更新商品状态
- **接口地址**: `/merchant/products/{id}/status`
- **请求方式**: PATCH
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **查询参数**:
  - `status`: 商品状态 (ON_SALE/OFF_SALE/OUT_OF_STOCK)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 5.7 商家更新商品库存
- **接口地址**: `/merchant/products/{id}/stock`
- **请求方式**: PATCH
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **查询参数**:
  - `stock`: 库存数量
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

## 6. 测试账号

### 6.1 普通用户测试账号

- **用户名**: HETAO
- **密码**: 7410852963
- **邮箱**: 13@FON.com
- **手机号**: 13800138005

### 6.2 商家测试账号

- **用户名**: MALL
- **密码**: 7410852963
- **邮箱**: MALL@SHOP.com
- **手机号**: 13800138202
- **角色**: MERCHANT

**商家 API 测试示例（PowerShell）**:

```powershell
# 1. 商家登录获取token
$headers = @{"Content-Type"="application/json"}
$body = @{username="MALL";password="7410852963"} | ConvertTo-Json
$response = Invoke-WebRequest -Uri "http://localhost/v1/auth/login" -Method POST -Headers $headers -Body $body -UseBasicParsing
$token = ($response.Content | ConvertFrom-Json).data.token

# 2. 添加商品
$headers = @{"Content-Type"="application/json";"Authorization"="Bearer $token"}
$body = @{
    title="天然维C片500mg"
    category="保健品"
    description="富含维生素C，增强免疫力，抗氧化"
    coverUrl="http://example.com/products/vitamin_c.jpg"
    features=@{brand="健康品牌";specification="500mg/片";origin="中国"}
    price=98.00
    stock=100
    status="ON_SALE"
} | ConvertTo-Json -Depth 3
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products" -Method POST -Headers $headers -Body $body -UseBasicParsing
$response.Content

# 3. 查询商品列表
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products?page=1&size=10" -Method GET -Headers $headers -UseBasicParsing
$response.Content

# 4. 修改商品
$body = @{
    title="天然维C片1000mg"
    category="保健品"
    description="高浓度维生素C，增强免疫力"
    coverUrl="http://example.com/products/vitamin_c_1000.jpg"
}
```