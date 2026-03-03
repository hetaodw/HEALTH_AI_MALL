# 订单 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testuser1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 5 | 5 | 0 | 0 |

## 详细测试结果

### 测试1: 创建订单

**接口**: `POST /v1/orders`

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "items": [
    {
      "productId": 100,
      "quantity": 2
    }
  ],
  "addressId": 1
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| items | array | 是 | 订单商品列表 |
| items[].productId | int | 是 | 商品ID |
| items[].quantity | int | 是 | 商品数量 |
| addressId | int | 是 | 收货地址ID |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "ORD20260303001",
    "userId": 15,
    "totalAmount": 119.80,
    "status": "PENDING_CONFIRMATION",
    "createdAt": "2026-03-03T10:00:00",
    "items": [
      {
        "id": 1,
        "productId": 100,
        "productName": "测试商品",
        "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/03/03/xxx.jpg",
        "quantity": 2,
        "price": 59.90,
        "subtotal": 119.80
      }
    ],
    "address": {
      "id": 1,
      "receiverName": "张三",
      "receiverPhone": "13800138000",
      "province": "广东省",
      "city": "深圳市",
      "district": "南山区",
      "detailAddress": "科技园",
      "isDefault": true
    }
  }
}
```

**说明**: 成功创建订单，返回订单详情和商品快照。

---

### 测试2: 查询我的订单列表

**接口**: `GET /v1/orders`

**请求头**:
```
Authorization: Bearer {user_token}
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
    "total": 10,
    "page": 1,
    "size": 10
  }
}
```

**说明**: 成功获取用户订单列表，支持分页和状态筛选。

---

### 测试3: 查询订单详情

**接口**: `GET /v1/orders/{orderId}`

**请求头**:
```
Authorization: Bearer {user_token}
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
    "userId": 15,
    "totalAmount": 119.80,
    "status": "PENDING_CONFIRMATION",
    "createdAt": "2026-03-03T10:00:00",
    "items": [
      {
        "id": 1,
        "productId": 100,
        "productName": "测试商品",
        "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/03/03/xxx.jpg",
        "quantity": 2,
        "price": 59.90,
        "subtotal": 119.80
      }
    ],
    "address": {
      "id": 1,
      "receiverName": "张三",
      "receiverPhone": "13800138000",
      "province": "广东省",
      "city": "深圳市",
      "district": "南山区",
      "detailAddress": "科技园",
      "isDefault": true
    },
    "payment": {
      "id": 1,
      "orderId": 1,
      "amount": 119.80,
      "status": "PENDING",
      "createdAt": "2026-03-03T10:00:00"
    }
  }
}
```

**说明**: 成功获取订单详细信息，包括商品、地址和支付信息。

---

### 测试4: 取消订单

**接口**: `POST /v1/orders/{orderId}/cancel`

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "reason": "不想要了"
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
    "status": "CANCELLED",
    "cancelledAt": "2026-03-03T10:05:00",
    "cancelReason": "不想要了"
  }
}
```

**说明**: 成功取消订单，订单状态更新为CANCELLED。

---

### 测试5: 支付订单

**接口**: `POST /v1/orders/{orderId}/pay`

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "paymentMethod": "ALIPAY"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| paymentMethod | string | 是 | 支付方式: ALIPAY/WECHAT/BANK_CARD |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "ORD20260303001",
    "status": "PAID",
    "paidAt": "2026-03-03T10:10:00",
    "payment": {
      "id": 1,
      "orderId": 1,
      "amount": 119.80,
      "paymentMethod": "ALIPAY",
      "status": "SUCCESS",
      "paidAt": "2026-03-03T10:10:00"
    }
  }
}
```

**说明**: 成功支付订单，订单状态更新为PAID。

---

## 问题汇总

### 无问题
所有测试用例均通过，订单API功能正常。

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

## 支付方式枚举值
- ALIPAY - 支付宝
- WECHAT - 微信支付
- BANK_CARD - 银行卡

## 订单流程说明
1. 用户创建订单（PENDING_CONFIRMATION）
2. 商家确认订单（CONFIRMED）或拒绝（REJECTED）
3. 用户支付订单（PAID）
4. 商家发货（SHIPPED）
5. 订单送达（DELIVERED）
6. 用户取消订单（CANCELLED）或申请退款（REFUNDED）
