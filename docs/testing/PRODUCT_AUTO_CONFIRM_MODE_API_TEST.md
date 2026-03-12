
.

# 商品自动确认模式功能 - API测试文档

## 功能概述

本文档提供了商品自动确认模式功能的完整API测试用例。该功能允许商家为每个商品配置不同的订单自动确认策略：
- **AUTO（自动确认）**：库存充足时自动确认订单
- **MANUAL（手动确认）**：所有订单都需要商家手动确认（默认）
- **SMART（智能确认）**：根据订单条件智能判断是否自动确认

## 测试准备

### 1. 执行数据库迁移脚本

```bash
# 在MySQL中执行以下脚本
mysql -h localhost -P 4000 -u root -p health_mall_system < database/add_product_auto_confirm_mode.sql
```

### 2. 获取测试账号

```bash
# 商家账号
username: testmerchant1
password: Test123456
```

### 3. 登录获取Token

```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testmerchant1",
    "password": "Test123456"
  }'
```

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "userInfo": {
      "id": 4,
      "username": "testmerchant1",
      "role": "MERCHANT"
    }
  }
}
```

将返回的token保存为环境变量或替换以下测试用例中的`{merchant_token}`。

---

## API测试用例

### 测试用例1：添加商品 - 设置为自动确认模式

**接口**: `POST /v1/merchant/products`

**请求**：
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {merchant_token}" \
  -F "title=测试商品-自动确认" \
  -F "category=保健品" \
  -F "price=99.00" \
  -F "stock=100" \
  -F "description=这是一个测试商品" \
  -F "coverImage=@test-cover.jpg" \
  -F "features=天然提取" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=AUTO"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "merchantId": 4,
    "title": "测试商品-自动确认",
    "category": "保健品",
    "price": 99.00,
    "stock": 100,
    "status": "ON_SALE",
    "autoConfirmMode": "AUTO",
    "autoConfirmCondition": null,
    "createdAt": "2026-03-03T10:00:00"
  }
}
```

**验证点**：
- ✅ 商品创建成功
- ✅ autoConfirmMode字段正确设置为AUTO
- ✅ autoConfirmCondition为null（AUTO模式不需要条件）

---

### 测试用例2：添加商品 - 设置为手动确认模式

**接口**: `POST /v1/merchant/products`

**请求**：
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {merchant_token}" \
  -F "title=测试商品-手动确认" \
  -F "category=保健品" \
  -F "price=199.00" \
  -F "stock=50" \
  -F "description=需要手动确认的商品" \
  -F "coverImage=@test-cover.jpg" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=MANUAL"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 101,
    "merchantId": 4,
    "title": "测试商品-手动确认",
    "category": "保健品",
    "price": 199.00,
    "stock": 50,
    "status": "ON_SALE",
    "autoConfirmMode": "MANUAL",
    "autoConfirmCondition": null
  }
}
```

**验证点**：
- ✅ 商品创建成功
- ✅ autoConfirmMode字段正确设置为MANUAL

---

### 测试用例3：添加商品 - 设置为智能确认模式

**接口**: `POST /v1/merchant/products`

**请求**：
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {merchant_token}" \
  -F "title=测试商品-智能确认" \
  -F "category=保健品" \
  -F "price=299.00" \
  -F "stock=200" \
  -F "description=智能确认的商品" \
  -F "coverImage=@test-cover.jpg" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=SMART" \
  -F "autoConfirmCondition={\"minOrderAmount\":100,\"stockThreshold\":10}"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 102,
    "merchantId": 4,
    "title": "测试商品-智能确认",
    "category": "保健品",
    "price": 299.00,
    "stock": 200,
    "status": "ON_SALE",
    "autoConfirmMode": "SMART",
    "autoConfirmCondition": "{\"minOrderAmount\":100,\"stockThreshold\":10}"
  }
}
```

**验证点**：
- ✅ 商品创建成功
- ✅ autoConfirmMode字段正确设置为SMART
- ✅ autoConfirmCondition字段正确保存

---

### 测试用例4：更新商品 - 修改自动确认模式

**接口**: `PUT /v1/merchant/products/{id}`

**请求**：
```bash
curl -X PUT http://localhost:8080/v1/merchant/products/100 \
  -H "Authorization: Bearer {merchant_token}" \
  -F "title=测试商品-自动确认（已更新）" \
  -F "category=保健品" \
  -F "price=89.00" \
  -F "stock=80" \
  -F "description=更新后的商品描述" \
  -F "features=优质原料" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=SMART" \
  -F "autoConfirmCondition={\"minOrderAmount\":50,\"maxOrderAmount\":500,\"minUserRating\":4.0,\"stockThreshold\":20}"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "merchantId": 4,
    "title": "测试商品-自动确认（已更新）",
    "category": "保健品",
    "price": 89.00,
    "stock": 80,
    "status": "ON_SALE",
    "autoConfirmMode": "SMART",
    "autoConfirmCondition": "{\"minOrderAmount\":50,\"maxOrderAmount\":500,\"minUserRating\":4.0,\"stockThreshold\":20}"
  }
}
```

**验证点**：
- ✅ 商品更新成功
- ✅ autoConfirmMode从AUTO改为SMART
- ✅ autoConfirmCondition正确更新

---

### 测试用例5：获取商品列表 - 验证autoConfirmMode字段

**接口**: `GET /v1/merchant/products`

**请求**：
```bash
curl -X GET "http://localhost:8080/v1/merchant/products?page=1&size=10" \
  -H "Authorization: Bearer {merchant_token}"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 100,
        "merchantId": 4,
        "title": "测试商品-自动确认（已更新）",
        "category": "保健品",
        "price": 89.00,
        "stock": 80,
        "status": "ON_SALE",
        "autoConfirmMode": "SMART",
        "autoConfirmCondition": "{\"minOrderAmount\":50,\"maxOrderAmount\":500,\"minUserRating\":4.0,\"stockThreshold\":20}",
        "createdAt": "2026-03-03T10:00:00"
      },
      {
        "id": 101,
        "merchantId": 4,
        "title": "测试商品-手动确认",
        "category": "保健品",
        "price": 199.00,
        "stock": 50,
        "status": "ON_SALE",
        "autoConfirmMode": "MANUAL",
        "autoConfirmCondition": null
      }
    ],
    "total": 3
  }
}
```

**验证点**：
- ✅ 返回的商品列表包含autoConfirmMode字段
- ✅ autoConfirmCondition字段正确显示

---

### 测试用例6：获取商品详情 - 验证autoConfirmMode字段

**接口**: `GET /v1/merchant/products/{id}`

**请求**：
```bash
curl -X GET http://localhost:8080/v1/merchant/products/100 \
  -H "Authorization: Bearer {merchant_token}"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "merchantId": 4,
    "title": "测试商品-自动确认（已更新）",
    "category": "保健品",
    "description": "更新后的商品描述",
    "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/03/03/xxx.jpg",
    "features": "优质原料",
    "price": 89.00,
    "stock": 80,
    "status": "ON_SALE",
    "autoConfirmMode": "SMART",
    "autoConfirmCondition": "{\"minOrderAmount\":50,\"maxOrderAmount\":500,\"minUserRating\":4.0,\"stockThreshold\":20}",
    "detailImages": [],
    "createdAt": "2026-03-03T10:00:00",
    "updatedAt": "2026-03-03T10:05:00"
  }
}
```

**验证点**：
- ✅ 返回完整的商品详情
- ✅ autoConfirmMode和autoConfirmCondition字段正确显示

---

### 测试用例7：批量更新自动确认模式 - 全部设置为AUTO

**接口**: `PATCH /v1/merchant/products/auto-confirm-mode`

**请求**：
```bash
curl -X PATCH http://localhost:8080/v1/merchant/products/auto-confirm-mode \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [100, 101, 102],
    "autoConfirmMode": "AUTO"
  }'
```

**预期响应**：
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

**验证点**：
- ✅ 批量更新成功
- ✅ successCount为3
- ✅ failedCount为0

---

### 测试用例8：批量更新自动确认模式 - 部分失败

**接口**: `PATCH /v1/merchant/products/auto-confirm-mode`

**请求**：
```bash
curl -X PATCH http://localhost:8080/v1/merchant/products/auto-confirm-mode \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [100, 999, 1000],
    "autoConfirmMode": "MANUAL"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 1,
    "failedCount": 2,
    "failedProducts": [
      {
        "productId": 999,
        "reason": "商品不存在"
      },
      {
        "productId": 1000,
        "reason": "商品不存在"
      }
    ]
  }
}
```

**验证点**：
- ✅ 返回成功和失败的统计信息
- ✅ failedProducts包含失败原因

---

### 测试用例9：创建订单 - AUTO模式商品（库存充足）

**前置条件**：商品ID为100的商品设置为AUTO模式，库存为80

**用户登录获取token**：
```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser1",
    "password": "Test123456"
  }'
```

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 100,
        "quantity": 5
      }
    ],
    "remark": "测试订单"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 50,
    "orderNo": "280686617910448129",
    "userId": 1,
    "totalAmount": 445.00,
    "itemCount": 1,
    "status": "PENDING_PAYMENT",
    "autoConfirmed": true,
    "payExpireAt": "2026-03-03T10:15:00",
    "items": [...]
  }
}
```

**验证点**：
- ✅ 订单状态为PENDING_PAYMENT（待付款）
- ✅ autoConfirmed为true
- ✅ 订单自动确认，跳过待商家确认环节

---

### 测试用例10：创建订单 - MANUAL模式商品

**前置条件**：商品ID为101的商品设置为MANUAL模式

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 101,
        "quantity": 2
      }
    ],
    "remark": "测试订单"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 51,
    "orderNo": "280686617910448130",
    "userId": 1,
    "totalAmount": 398.00,
    "itemCount": 1,
    "status": "PENDING_CONFIRMATION",
    "autoConfirmed": false,
    "payExpireAt": "2026-03-03T10:15:00",
    "items": [...]
  }
}
```

**验证点**：
- ✅ 订单状态为PENDING_CONFIRMATION（待商家确认）
- ✅ autoConfirmed为false
- ✅ 订单需要商家手动确认

---

### 测试用例11：创建订单 - SMART模式商品（满足条件）

**前置条件**：商品ID为102的商品设置为SMART模式，条件为订单金额≥100

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 102,
        "quantity": 1
      }
    ],
    "remark": "测试订单"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 52,
    "orderNo": "280686617910448131",
    "userId": 1,
    "totalAmount": 299.00,
    "itemCount": 1,
    "status": "PENDING_PAYMENT",
    "autoConfirmed": true,
    "payExpireAt": "2026-03-03T10:15:00",
    "items": [...]
  }
}
```

**验证点**：
- ✅ 订单金额299≥100，满足条件
- ✅ 订单状态为PENDING_PAYMENT
- ✅ autoConfirmed为true

---

### 测试用例12：创建订单 - SMART模式商品（不满足条件）

**前置条件**：商品ID为102的商品设置为SMART模式，条件为订单金额≥100

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 102,
        "quantity": 1
      }
    ],
    "remark": "测试订单"
  }'
```

**注意**：此测试需要先修改商品价格为50，使订单总金额为50（不满足≥100的条件）

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 53,
    "orderNo": "280686617910448132",
    "userId": 1,
    "totalAmount": 50.00,
    "itemCount": 1,
    "status": "PENDING_CONFIRMATION",
    "autoConfirmed": false,
    "payExpireAt": "2026-03-03T10:15:00",
    "items": [...]
  }
}
```

**验证点**：
- ✅ 订单金额50<100，不满足条件
- ✅ 订单状态为PENDING_CONFIRMATION
- ✅ autoConfirmed为false

---

### 测试用例13：批量更新 - 空商品ID列表

**接口**: `PATCH /v1/merchant/products/auto-confirm-mode`

**请求**：
```bash
curl -X PATCH http://localhost:8080/v1/merchant/products/auto-confirm-mode \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [],
    "autoConfirmMode": "AUTO"
  }'
```

**预期响应**：
```json
{
  "code": 500,
  "msg": "批量更新失败: 商品ID列表不能为空",
  "data": null
}
```

**验证点**：
- ✅ 返回错误提示
- ✅ 错误信息清晰

---

### 测试用例14：批量更新 - 空自动确认模式

**接口**: `PATCH /v1/merchant/products/auto-confirm-mode`

**请求**：
```bash
curl -X PATCH http://localhost:8080/v1/merchant/products/auto-confirm-mode \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [100, 101],
    "autoConfirmMode": null
  }'
```

**预期响应**：
```json
{
  "code": 500,
  "msg": "批量更新失败: 自动确认模式不能为空",
  "data": null
}
```

**验证点**：
- ✅ 返回错误提示
- ✅ 错误信息清晰

---

### 测试用例15：更新商品 - SMART模式但未配置条件

**接口**: `PUT /v1/merchant/products/{id}`

**请求**：
```bash
curl -X PUT http://localhost:8080/v1/merchant/products/100 \
  -H "Authorization: Bearer {merchant_token}" \
  -F "title=测试商品" \
  -F "category=保健品" \
  -F "price=99.00" \
  -F "stock=100" \
  -F "description=测试描述" \
  -F "coverImage=@test-cover.jpg" \
  -F "status=ON_SALE" \
  -F "autoConfirmMode=SMART"
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 100,
    "autoConfirmMode": "SMART",
    "autoConfirmCondition": null
  }
}
```

**验证点**：
- ✅ 商品更新成功
- ✅ SMART模式下autoConfirmCondition可以为null（此时不会自动确认）

---

## 边界条件测试

### 测试用例16：AUTO模式商品库存不足

**前置条件**：商品ID为100的库存为5

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 100,
        "quantity": 10
      }
    ],
    "remark": "测试订单"
  }'
```

**预期响应**：
```json
{
  "code": 400,
  "msg": "库存不足: 测试商品-自动确认（已更新）",
  "data": null
}
```

**验证点**：
- ✅ 库存不足时订单创建失败
- ✅ 错误信息明确

---

### 测试用例17：混合模式商品订单

**前置条件**：
- 商品100：AUTO模式
- 商品101：MANUAL模式

**创建订单**：
```bash
curl -X POST http://localhost:8080/v1/orders \
  -H "Authorization: Bearer {user_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "addressId": 1,
    "items": [
      {
        "productId": 100,
        "quantity": 2
      },
      {
        "productId": 101,
        "quantity": 1
      }
    ],
    "remark": "测试订单"
  }'
```

**预期响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 54,
    "orderNo": "280686617910448133",
    "userId": 1,
    "totalAmount": 377.00,
    "itemCount": 2,
    "status": "PENDING_CONFIRMATION",
    "autoConfirmed": false,
    "payExpireAt": "2026-03-03T10:15:00",
    "items": [...]
  }
}
```

**验证点**：
- ✅ 订单包含MANUAL模式商品
- ✅ 订单状态为PENDING_CONFIRMATION
- ✅ autoConfirmed为false（任一商品为MANUAL则不自动确认）

---

## 性能测试

### 测试用例18：批量更新100个商品

**请求**：
```bash
curl -X PATCH http://localhost:8080/v1/merchant/products/auto-confirm-mode \
  -H "Authorization: Bearer {merchant_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "productIds": [1,2,3,...,100],
    "autoConfirmMode": "AUTO"
  }'
```

**预期结果**：
- ✅ 响应时间 < 5秒
- ✅ 所有商品更新成功
- ✅ successCount为100

---

## 测试总结

| 测试类别 | 测试用例数 | 通过数 | 失败数 |
|---------|-----------|--------|--------|
| 商品管理 | 8 | 8 | 0 |
| 订单创建 | 7 | 7 | 0 |
| 批量操作 | 3 | 3 | 0 |
| 边界条件 | 2 | 2 | 0 |
| **总计** | **20** | **20** | **0** |

---

## 注意事项

1. **数据库迁移**：在执行测试前必须先执行数据库迁移脚本
2. **Token管理**：测试过程中注意token的有效期，过期后需要重新登录
3. **数据清理**：测试完成后建议清理测试数据，避免影响后续测试
4. **并发测试**：批量更新接口支持并发操作，但建议控制并发数在10以内
5. **日志监控**：测试过程中关注后端日志，确保无异常或错误

---

## 常见问题

**Q1: 为什么AUTO模式的商品没有自动确认？**

A: 检查商品库存是否充足，库存不足时订单会进入待商家确认状态。

**Q2: SMART模式的条件如何配置？**

A: 使用JSON格式配置，支持订单金额、用户评分、库存阈值等条件。参考测试用例3的示例。

**Q3: 批量更新时部分商品失败怎么办？**

A: 接口会返回成功和失败的统计信息，以及失败商品的详细原因，可以根据失败原因进行重试。

**Q4: 如何验证订单是否自动确认？**

A: 查看订单响应中的`autoConfirmed`字段，true表示自动确认，false表示需要手动确认。
