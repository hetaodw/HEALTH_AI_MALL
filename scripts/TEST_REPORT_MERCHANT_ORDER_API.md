# 商家订单管理 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testmerchant1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 4 | 4 | 0 | 0 |

## 详细测试结果

### 测试1: 获取待确认订单列表

**接口**: `GET /v1/merchant/orders/pending`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |

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
        "orderNo": "ORD20260303001",
        "userId": 15,
        "username": "testuser1",
        "totalAmount": 119.80,
        "status": "PENDING_CONFIRMATION",
        "createdAt": "2026-03-03T10:00:00",
        "items": [
          {
            "productId": 100,
            "productName": "测试商品",
            "quantity": 2,
            "price": 59.90
          }
        ]
      }
    ],
    "total": 5,
    "page": 1,
    "size": 10
  }
}
```

**说明**: 成功获取待确认订单列表，包含订单详情和商品信息。

---

### 测试2: 获取商家订单列表

**接口**: `GET /v1/merchant/orders`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**查询参数**:
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |
| size | int | 否 | 10 | 每页数量 |
| status | string | 否 | - | 订单状态筛选 |

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
        "orderNo": "ORD20260303001",
        "userId": 15,
        "username": "testuser1",
        "totalAmount": 119.80,
        "status": "PENDING_CONFIRMATION",
        "createdAt": "2026-03-03T10:00:00",
        "items": [
          {
            "productId": 100,
            "productName": "测试商品",
            "quantity": 2,
            "price": 59.90
          }
        ]
      }
    ],
    "total": 20,
    "page": 1,
    "size": 10
  }
}
```

**说明**: 成功获取商家订单列表，支持分页和状态筛选。

---

### 测试3: 确认订单

**接口**: `POST /v1/merchant/orders/{orderId}/confirm`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**请求体**:
```json
{
  "confirm": true
}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "ORD20260303001",
    "status": "CONFIRMED",
    "confirmedAt": "2026-03-03T10:05:00"
  }
}
```

**说明**: 成功确认订单，订单状态更新为CONFIRMED。

---

### 测试4: 拒绝订单

**接口**: `POST /v1/merchant/orders/{orderId}/confirm`

**请求头**:
```
Authorization: Bearer {merchant_token}
```

**请求体**:
```json
{
  "confirm": false,
  "reason": "库存不足"
}
```

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 2,
    "orderNo": "ORD20260303002",
    "status": "REJECTED",
    "rejectedAt": "2026-03-03T10:10:00",
    "rejectReason": "库存不足"
  }
}
```

**说明**: 成功拒绝订单，订单状态更新为REJECTED，并记录拒绝原因。

---

## 问题汇总

### 无问题
所有测试用例均通过，商家订单管理API功能正常。

## 测试数据保存
- 测试脚本: 已包含在相关测试中

## 订单状态枚举值
- PENDING_CONFIRMATION - 待确认
- CONFIRMED - 已确认
- REJECTED - 已拒绝
- PENDING_PAYMENT - 待支付
- PAID - 已支付
- SHIPPED - 已发货
- DELIVERED - 已送达
- CANCELLED - 已取消
- REFUNDED - 已退款

## 自动确认模式说明
- AUTO: 订单自动确认，无需商家操作
- MANUAL: 订单需要商家手动确认
- SMART: 根据智能条件自动确认订单
