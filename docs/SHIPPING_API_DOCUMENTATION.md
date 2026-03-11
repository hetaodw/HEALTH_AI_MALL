# Health Mall 发货功能新增 API 文档

## 目录

- [风控校验 API](#风控校验-api)
  - [1. 订单风控检查](#1-订单风控检查)
  - [2. 获取订单风控记录](#2-获取订单风控记录)
  - [3. 人工审核风控记录](#3-人工审核风控记录)
  - [4. 获取待审核风控记录](#4-获取待审核风控记录)
- [物流管理 API](#物流管理-api)
  - [5. 申请电子面单](#5-申请电子面单)
  - [6. 查询物流信息](#6-查询物流信息)
- [商家发货 API](#商家发货-api)
  - [7. 订单发货](#7-订单发货)
- [测试用例 (cURL)](#测试用例-curl)

---

## 风控校验 API

### 1. 订单风控检查

**接口**: `POST /admin/risk-control/orders/{orderNo}/check`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求头**: `Authorization: Bearer {admin_token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "202603101234567890",
    "userId": 1,
    "ruleId": null,
    "riskLevel": "LOW",
    "status": "APPROVED",
    "riskScore": 0,
    "riskReason": "",
    "reviewerId": null,
    "reviewComment": null,
    "reviewedAt": null,
    "createdAt": "2026-03-10T10:00:00"
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | long | 风控记录ID |
| orderNo | string | 订单号 |
| userId | int | 用户ID |
| riskLevel | enum | 风险等级: LOW(低风险), MEDIUM(中风险), HIGH(高风险), CRITICAL(严重风险) |
| status | enum | 风控状态: PENDING(待处理), APPROVED(通过), REJECTED(拒绝), MANUAL_REVIEW(人工审核) |
| riskScore | int | 风险评分 |
| riskReason | string | 风险原因 |
| reviewerId | int | 审核人ID |
| reviewComment | string | 审核意见 |
| reviewedAt | datetime | 审核时间 |
| createdAt | datetime | 创建时间 |

---

### 2. 获取订单风控记录

**接口**: `GET /admin/risk-control/orders/{orderNo}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求头**: `Authorization: Bearer {admin_token}`

**响应示例**: 同订单风控检查

---

### 3. 人工审核风控记录

**接口**: `POST /admin/risk-control/records/{recordId}/review`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| recordId | long | 风控记录ID |

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| reviewerId | int | 是 | 审核人ID |
| comment | string | 是 | 审核意见 |
| approved | boolean | 是 | 是否通过 |

**请求头**: `Authorization: Bearer {admin_token}`

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

---

### 4. 获取待审核风控记录

**接口**: `GET /admin/risk-control/records/pending`

**请求头**: `Authorization: Bearer {admin_token}`

**说明**: 获取最近7天内需要人工审核的风控记录

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 2,
      "orderNo": "202603101234567891",
      "userId": 2,
      "riskLevel": "HIGH",
      "status": "MANUAL_REVIEW",
      "riskScore": 60,
      "riskReason": "订单金额超过阈值; 频繁下单",
      "createdAt": "2026-03-10T09:00:00"
    }
  ]
}
```

---

## 物流管理 API

### 5. 申请电子面单

**接口**: `POST /merchant/logistics/waybill`

**请求头**: `Authorization: Bearer {merchant_token}`

**请求体**:
```json
{
  "orderNo": "202603101234567890",
  "logisticsCompany": "SF"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| orderNo | string | 是 | 订单号 |
| logisticsCompany | enum | 是 | 物流公司: SF(顺丰), STO(申通), YTO(圆通), ZTO(中通), EMS(EMS) |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "202603101234567890",
    "logisticsCompany": "SF",
    "trackingNo": "SF1234567890123",
    "waybillUrl": "https://www.sf.com/waybill/SF1234567890123",
    "status": "CREATED",
    "estimatedDelivery": "2026-03-13T10:00:00",
    "deliveredAt": null,
    "traceInfo": null,
    "createdAt": "2026-03-10T10:00:00",
    "updatedAt": "2026-03-10T10:00:00"
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | long | 物流记录ID |
| orderNo | string | 订单号 |
| logisticsCompany | enum | 物流公司 |
| trackingNo | string | 运单号 |
| waybillUrl | string | 面单URL |
| status | enum | 物流状态: CREATED(已创建), PICKED(已揽收), IN_TRANSIT(运输中), DELIVERED(已送达), EXCEPTION(异常) |
| estimatedDelivery | datetime | 预计送达时间 |
| deliveredAt | datetime | 实际送达时间 |
| traceInfo | string | 物流轨迹信息 |
| createdAt | datetime | 创建时间 |
| updatedAt | datetime | 更新时间 |

---

### 6. 查询物流信息

**接口**: `GET /merchant/logistics/{orderNo}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求头**: `Authorization: Bearer {merchant_token}`

**响应示例**: 同申请电子面单

---

## 商家发货 API

### 7. 订单发货

**接口**: `POST /merchant/orders/{orderNo}/ship`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求头**: `Authorization: Bearer {merchant_token}`

**请求体**:
```json
{
  "trackingNo": "SF1234567890123",
  "logisticsCompany": "SF"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| trackingNo | string | 是 | 运单号 |
| logisticsCompany | enum | 是 | 物流公司 |

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "202603101234567890",
    "userId": 1,
    "totalAmount": 59.90,
    "itemCount": 1,
    "status": "SHIPPED",
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "receiverAddress": "北京市朝阳区xxx",
    "paidAt": "2026-03-10T09:30:00",
    "shippedAt": "2026-03-10T10:00:00",
    "createdAt": "2026-03-10T09:00:00",
    "items": [
      {
        "id": 1,
        "productId": 1,
        "quantity": 1,
        "unitPrice": 59.90,
        "totalPrice": 59.90,
        "productTitle": "维生素C片",
        "productCoverUrl": "http://example.com/product1.jpg",
        "category": "VITAMINS",
        "merchantName": "官方店铺"
      }
    ]
  }
}
```

**业务逻辑**:
1. 验证订单是否属于当前商家
2. 验证订单状态是否为PAID（已付款）
3. 验证风控是否通过
4. 验证电子面单是否存在且运单号匹配
5. 更新订单状态为SHIPPED（已发货）
6. 更新物流状态为PICKED（已揽收）
7. 发送发货通知（站内信功能开发后实现）

---

## 测试用例 (cURL)

### 风控校验

#### 1. 订单风控检查
```bash
curl -X POST http://localhost:8080/admin/risk-control/orders/202603101234567890/check \
  -H "Authorization: Bearer {admin_token}"
```

#### 2. 获取订单风控记录
```bash
curl -X GET http://localhost:8080/admin/risk-control/orders/202603101234567890 \
  -H "Authorization: Bearer {admin_token}"
```

#### 3. 人工审核风控记录
```bash
curl -X POST "http://localhost:8080/admin/risk-control/records/1/review?reviewerId=1&comment=审核通过&approved=true" \
  -H "Authorization: Bearer {admin_token}"
```

#### 4. 获取待审核风控记录
```bash
curl -X GET http://localhost:8080/admin/risk-control/records/pending \
  -H "Authorization: Bearer {admin_token}"
```

---

### 物流管理

#### 5. 申请电子面单
```bash
curl -X POST http://localhost:8080/merchant/logistics/waybill \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "orderNo": "202603101234567890",
    "logisticsCompany": "SF"
  }'
```

#### 6. 查询物流信息
```bash
curl -X GET http://localhost:8080/merchant/logistics/202603101234567890 \
  -H "Authorization: Bearer {merchant_token}"
```

---

### 商家发货

#### 7. 订单发货
```bash
curl -X POST http://localhost:8080/merchant/orders/202603101234567890/ship \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "trackingNo": "SF1234567890123",
    "logisticsCompany": "SF"
  }'
```

---

## 业务流程说明

### 完整发货流程

```
用户下单 → 商家确认 → 用户支付 → 风控校验 → 申请电子面单 → 订单发货 → 物流跟踪
```

### 详细步骤

1. **用户下单**: 用户创建订单，订单状态为PENDING_CONFIRMATION（待商家确认）
2. **商家确认**: 商家确认订单，订单状态变为CONFIRMED（已确认）或自动确认后变为PENDING_PAYMENT（待付款）
3. **用户支付**: 用户支付订单，订单状态变为PAID（已付款）
4. **风控校验**: 
   - 系统自动进行风控检查
   - 低风险订单自动通过
   - 高风险订单需要人工审核
5. **申请电子面单**: 商家为订单申请电子面单，获取运单号
6. **订单发货**: 商家填写运单号并确认发货
7. **物流跟踪**: 订单状态变为SHIPPED（已发货），物流状态变为PICKED（已揽收）

---

## 风控规则说明

### 风险评分规则

| 规则 | 风险分数 | 说明 |
|------|----------|------|
| 订单金额超过10000元 | +30 | 大额订单风险较高 |
| 用户在黑名单 | +100 | 黑名单用户禁止交易 |
| 1小时内下单超过5次 | +20 | 频繁下单可能存在刷单风险 |

### 风险等级判定

| 风险分数 | 风险等级 | 处理方式 |
|----------|----------|----------|
| 0-19 | LOW | 自动通过 |
| 20-49 | MEDIUM | 自动通过 |
| 50-79 | HIGH | 人工审核 |
| 80+ | CRITICAL | 人工审核 |

---

## 物流公司说明

| 物流公司 | 代码 | 说明 |
|----------|------|------|
| 顺丰速运 | SF | 快速、可靠，适合高价值商品 |
| 申通快递 | STO | 性价比高，覆盖范围广 |
| 圆通速递 | YTO | 价格实惠，时效稳定 |
| 中通快递 | ZTO | 网络覆盖广，价格优惠 |
| EMS | EMS | 邮政特快，覆盖全国 |

---

## 注意事项

1. **风控校验**: 订单发货前必须通过风控校验，否则无法发货
2. **电子面单**: 发货前必须先申请电子面单，获取运单号
3. **订单状态**: 只有PAID（已付款）状态的订单才能发货
4. **运单号匹配**: 发货时填写的运单号必须与电子面单的运单号一致
5. **权限控制**: 风控校验API需要管理员权限，物流和发货API需要商家权限
6. **发货通知**: 发货通知功能将在站内信功能开发后实现

---

## 数据库表结构

### risk_control_records（风控记录表）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | bigint | 主键 |
| order_no | varchar(32) | 订单号（唯一） |
| user_id | int | 用户ID |
| rule_id | varchar(50) | 规则ID |
| risk_level | varchar(20) | 风险等级 |
| status | varchar(20) | 风控状态 |
| risk_score | int | 风险评分 |
| risk_reason | varchar(500) | 风险原因 |
| reviewer_id | int | 审核人ID |
| review_comment | varchar(500) | 审核意见 |
| reviewed_at | datetime | 审核时间 |
| created_at | datetime | 创建时间 |

### logistics_info（物流信息表）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | bigint | 主键 |
| order_no | varchar(32) | 订单号（唯一） |
| logistics_company | varchar(20) | 物流公司 |
| tracking_no | varchar(50) | 运单号 |
| waybill_url | varchar(255) | 面单URL |
| status | varchar(20) | 物流状态 |
| estimated_delivery | datetime | 预计送达时间 |
| delivered_at | datetime | 实际送达时间 |
| trace_info | text | 物流轨迹信息 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 400 | 请求参数错误或业务规则不满足 |
| 401 | 未授权，请先登录 |
| 403 | 无权操作此资源 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 后续开发计划

1. **发货通知**: 集成站内信、短信、邮件通知功能
2. **物流跟踪**: 对接真实物流公司API，实时获取物流轨迹
3. **自动发货**: 根据物流状态自动更新订单状态
4. **物流评价**: 用户对物流服务进行评价
5. **异常处理**: 处理物流异常、退换货等场景
