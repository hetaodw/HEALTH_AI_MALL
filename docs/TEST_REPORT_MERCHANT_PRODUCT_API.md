# 商家商品管理 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testmerchant1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 8 | 8 | 0 | 0 |

## 详细测试结果

### 测试1: 添加商品

**接口**: `POST /v1/merchant/products`

**请求头**:
```
Authorization: Bearer {merchant_token}
Content-Type: multipart/form-data
```

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | 是 | 商品标题 |
| category | string | 是 | 商品分类 |
| description | string | 是 | 商品描述 |
| coverImage | file | 是 | 封面图片文件 |
| features | string | 否 | 商品特性（JSON格式字符串） |
| price | decimal | 是 | 价格 |
| stock | int | 是 | 库存 |
| status | string | 否 | 状态: ON_SALE/OFF_SALE/OUT_OF_STOCK，默认ON_SALE |
| autoConfirmMode | string | 否 | 自动确认模式: AUTO/MANUAL/SMART，默认MANUAL |
| autoConfirmCondition | string | 否 | 智能确认条件（JSON格式），仅在SMART模式下有效 |
| detailImages | file[] | 否 | 商品详情图片列表（可选） |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "title": "测试商品",
    "category": "HEALTH_PRODUCTS",
    "price": 59.90,
    "stock": 100,
    "status": "ON_SALE",
    "autoConfirmMode": "MANUAL",
    "autoConfirmCondition": null,
    "createdAt": "2026-03-03T10:00:00"
  }
}
```

**说明**: 成功添加商品，返回商品ID和详细信息。

---

### 测试2: 获取商家商品列表

**接口**: `GET /v1/merchant/products`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |
| status | string | 否 | - | 商品状态筛选 |
| category | string | 否 | - | 商品分类筛选 |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 100,
        "title": "测试商品",
        "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/03/03/xxx.jpg",
        "price": 59.90,
        "stock": 100,
        "category": "HEALTH_PRODUCTS",
        "status": "ON_SALE",
        "autoConfirmMode": "MANUAL",
        "createdAt": "2026-03-03T10:00:00"
      }
    ],
    "total": 10,
    "page": 1,
    "size": 10
  }
}
```

**说明**: 成功获取商家商品列表，支持分页和筛选。

---

### 测试3: 获取商家商品详情

**接口**: `GET /v1/merchant/products/{id}`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "title": "测试商品",
    "category": "HEALTH_PRODUCTS",
    "description": "测试商品描述",
    "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/03/03/xxx.jpg",
    "features": "{\"brand\":\"测试品牌\",\"specification\":\"100mg/片\"}",
    "price": 59.90,
    "stock": 100,
    "sales": 0,
    "status": "ON_SALE",
    "autoConfirmMode": "MANUAL",
    "autoConfirmCondition": null,
    "createdAt": "2026-03-03T10:00:00",
    "detailImages": [
      "http://localhost:8080/v1/static/product/detail/2026/03/03/detail1.jpg"
    ]
  }
}
```

**说明**: 成功获取商品详细信息。

---

### 测试4: 更新商品

**接口**: `PUT /v1/merchant/products/{id}`

**请求头**:
```
Authorization: Bearer {merchant_token}
Content-Type: multipart/form-data
```

**请求参数**: 与添加商品相同，所有字段均为可选

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "title": "更新后的商品标题",
    "price": 69.90,
    "stock": 150,
    "status": "ON_SALE"
  }
}
```

**说明**: 成功更新商品信息。

---

### 测试5: 更新商品状态

**接口**: `PUT /v1/merchant/products/{id}/status`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**请求体**:
```json
{
  "status": "OFF_SALE"
}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**说明**: 成功更新商品状态。

---

### 测试6: 更新商品库存

**接口**: `PUT /v1/merchant/products/{id}/stock`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**请求体**:
```json
{
  "stock": 200
}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**说明**: 成功更新商品库存。

---

### 测试7: 批量更新自动确认模式

**接口**: `POST /v1/merchant/products/batch/auto-confirm-mode`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**请求体**:
```json
{
  "productIds": [100, 101, 102],
  "autoConfirmMode": "AUTO",
  "autoConfirmCondition": null
}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 3,
    "failedCount": 0,
    "failedProducts": []
  }
}
```

**说明**: 成功批量更新商品的自动确认模式。

---

### 测试8: 删除商品

**接口**: `DELETE /v1/merchant/products/{id}`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**说明**: 成功删除商品。

---

## 问题汇总

### 无问题
所有测试用例均通过，商家商品管理API功能正常。

## 测试数据保存
- 测试脚本: 已包含在相关测试中

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

## 自动确认模式枚举值
- AUTO - 自动确认
- MANUAL - 手动确认
- SMART - 智能确认

## 商品特性 (features) 格式示例
```json
{
  "brand": "品牌名称",
  "specification": "规格说明",
  "origin": "产地",
  "shelfLife": "保质期"
}
```
