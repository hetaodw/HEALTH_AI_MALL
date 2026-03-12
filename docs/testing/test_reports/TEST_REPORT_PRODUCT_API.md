# 商品相关 API 测试报告（用户端）

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 9 | 9 | 0 | 0 |

## 详细测试结果

### 测试1: 获取商品列表（默认）

**接口**: `GET /v1/products`

**测试结果**: ✅ 通过

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
        "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
        "price": 999.00,
        "stock": 99,
        "category": "HEALTH_PRODUCTS",
        "isHot": true
      }
    ],
    "total": 50
  }
}
```

**说明**: 成功获取商品列表，返回分页数据。

---

### 测试2: 获取商品列表（带分页）

**接口**: `GET /v1/products?page=1&size=5`

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [...],
    "total": 50,
    "page": 1,
    "size": 5
  }
}
```

**说明**: 成功获取带分页的商品列表。

---

### 测试3: 获取热门商品

**接口**: `GET /v1/products/hot?limit=5`

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 1,
      "title": "天然维C片500mg",
      "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
      "price": 999.00,
      "stock": 99,
      "category": "HEALTH_PRODUCTS",
      "isHot": true
    }
  ]
}
```

**说明**: 成功获取热门商品列表，所有商品isHot字段为true。

---

### 测试4: 搜索商品

**接口**: `GET /v1/products/search?keyword=维&page=1&size=5`

**测试结果**: ✅ 通过

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
        "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
        "price": 999.00,
        "stock": 99,
        "category": "HEALTH_PRODUCTS",
        "isHot": true
      }
    ],
    "total": 10
  }
}
```

**说明**: 成功根据关键词搜索商品。

---

### 测试5: 获取商品详情

**接口**: `GET /v1/products/{id}`

**测试结果**: ✅ 通过

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

**说明**: 成功获取商品详细信息，包括商家信息、商品详情和详细介绍图片列表。

---

### 测试6: 按分类获取商品

**接口**: `GET /v1/products/category/HEALTH_PRODUCTS?page=1&size=5`

**测试结果**: ✅ 通过

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
        "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
        "price": 999.00,
        "stock": 99,
        "category": "HEALTH_PRODUCTS",
        "isHot": true
      }
    ],
    "total": 20
  }
}
```

**说明**: 成功按分类获取商品列表。

---

### 测试7: 获取商品列表（带价格过滤）

**接口**: `GET /v1/products?minPrice=10&maxPrice=100&page=1&size=5`

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [...],
    "total": 15
  }
}
```

**说明**: 成功获取价格在指定范围内的商品。

---

### 测试8: 获取商品列表（带排序）

**接口**: `GET /v1/products?sortBy=price&sortOrder=asc&page=1&size=5`

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 5,
        "title": "商品A",
        "price": 10.00
      },
      {
        "id": 3,
        "title": "商品B",
        "price": 20.00
      }
    ],
    "total": 50
  }
}
```

**说明**: 成功按价格升序获取商品列表。

---

### 测试9: 获取商品列表（带热门过滤）

**接口**: `GET /v1/products?isHot=true&page=1&size=5`

**测试结果**: ✅ 通过

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
        "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
        "price": 999.00,
        "stock": 99,
        "category": "HEALTH_PRODUCTS",
        "isHot": true
      }
    ],
    "total": 10
  }
}
```

**说明**: 成功获取热门商品列表，所有商品isHot字段为true。

---

## 问题汇总

### 无问题
所有测试用例均通过，商品相关API（用户端）功能正常。

## 测试数据保存
- CSV结果文件: `scripts/test_product_api_results.csv`
- 测试脚本: `scripts/test_product_api.ps1`

## 全局变量（用于后续测试）
- `$global:productId`: 商品ID（用于后续测试）

## 商品分类枚举值
- HEALTH_PRODUCTS - 保健品
- MEDICAL_DEVICES - 医疗器械
- HEALTH_FOOD - 健康食品
- SPORTS_FITNESS - 运动健身
- MATERNAL_BABY - 母婴用品

## 商品状态枚举值
- ON_SALE - 在售
- OFF_SALE - 下架
- OUT_OF_STOCK - 缺货
