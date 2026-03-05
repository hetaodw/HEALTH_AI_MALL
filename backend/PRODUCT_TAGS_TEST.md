# 商品标签功能 - API测试文档

## 测试环境

- **后端服务**: http://localhost:8080
- **AI服务**: http://localhost:5000
- **数据库**: health_mall_system
- **测试账号**:
  - 商家: testmerchant1 / Test123456
  - 用户: testuser1 / Test123456

## 测试准备

### 1. 获取测试Token

```bash
# 商家登录
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testmerchant1","password":"Test123456"}'

# 保存返回的token，后续测试使用
# 假设返回: {"code":200,"data":{"token":"eyJhbGciOiJIUzI1NiJ9..."}}
```

**预期结果**:
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

---

## 测试用例

### 测试1：为商品生成标签

**测试ID**: TC-001
**优先级**: 🔴 高
**接口**: `POST /v1/products/tags/{productId}/generate`

**测试目的**: 验证AI模型调用和标签生成功能

**前置条件**:
- 已登录获取token
- 存在商品ID（如：1）

**测试步骤**:
```bash
curl -X POST http://localhost:8080/v1/products/tags/1/generate \
  -H "Authorization: Bearer {token}"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] 返回的tags数组不为空
- [ ] tags中每个标签都是字符串类型
- [ ] 数据库products表中features字段已更新为JSON数组格式
- [ ] 数据库products表中need_regenerate_tags字段为false

**数据库验证SQL**:
```sql
SELECT id, features, need_regenerate_tags 
FROM products 
WHERE id = 1;
```

**预期输出**:
```
id | features | need_regenerate_tags
----|----------|--------------------
1   | ["维生素","增强免疫力","抗氧化","天然原料"] | 0
```

---

### 测试2：获取商品标签

**测试ID**: TC-002
**优先级**: 🔴 高
**接口**: `GET /v1/products/tags/{productId}`

**测试目的**: 验证标签查询功能

**前置条件**:
- 商品已有标签（执行TC-001后）

**测试步骤**:
```bash
curl -X GET http://localhost:8080/v1/products/tags/1
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] data字段为字符串数组
- [ ] 数组内容与生成的一致

---

### 测试3：手动更新商品标签

**测试ID**: TC-003
**优先级**: 🔴 高
**接口**: `PUT /v1/products/tags/{productId}`

**测试目的**: 验证商家手动修改标签功能

**前置条件**:
- 已登录获取token

**测试步骤**:
```bash
curl -X PUT http://localhost:8080/v1/products/tags/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"tags": ["维生素", "增强免疫力", "抗氧化", "天然原料", "新品推荐"]}'
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] 数据库中tags已更新
- [ ] need_regenerate_tags设置为false

**数据库验证SQL**:
```sql
SELECT features, need_regenerate_tags 
FROM products 
WHERE id = 1;
```

**预期输出**:
```
features | need_regenerate_tags
----------|--------------------
["维生素","增强免疫力","抗氧化","天然原料","新品推荐"] | 0
```

---

### 测试4：批量生成商品标签

**测试ID**: TC-004
**优先级**: 🟡 中
**接口**: `POST /v1/products/tags/batch/generate`

**测试目的**: 验证批量处理功能

**前置条件**:
- 已登录获取token
- 存在多个商品ID

**测试步骤**:
```bash
curl -X POST http://localhost:8080/v1/products/tags/batch/generate \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"productIds": [1, 2, 3, 4, 5]}'
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 5,
    "failedCount": 0,
    "failedProductIds": [],
    "message": "批量生成完成：成功5个，失败0个"
  }
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] successCount等于请求的商品数量
- [ ] failedCount为0
- [ ] 所有商品的features字段都已更新

**数据库验证SQL**:
```sql
SELECT id, features, need_regenerate_tags 
FROM products 
WHERE id IN (1, 2, 3, 4, 5)
ORDER BY id;
```

---

### 测试5：获取热门标签

**测试ID**: TC-005
**优先级**: 🟡 中
**接口**: `GET /v1/products/tags/popular`

**测试目的**: 验证标签统计功能

**前置条件**:
- 系统中已有多个商品且生成了标签

**测试步骤**:
```bash
curl -X GET "http://localhost:8080/v1/products/tags/popular?limit=10"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {"tag": "维生素", "count": 50},
    {"tag": "增强免疫力", "count": 45},
    {"tag": "抗氧化", "count": 38},
    {"tag": "天然原料", "count": 32},
    {"tag": "新品推荐", "count": 15}
  ]
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] data字段为对象数组
- [ ] 每个对象包含tag和count字段
- [ ] 结果按count降序排列
- [ ] 返回数量不超过limit参数

**数据库验证SQL**:
```sql
SELECT 
  JSON_UNQUOTE(JSON_EXTRACT(features, CONCAT('$[', idx, ']'))) AS tag,
  COUNT(*) AS count
FROM products 
WHERE features IS NOT NULL 
  AND features != '[]'
  AND features != ''
GROUP BY tag
ORDER BY count DESC
LIMIT 10;
```

---

### 测试6：按标签搜索商品

**测试ID**: TC-006
**优先级**: 🟡 中
**接口**: `GET /v1/products/tags/search`

**测试目的**: 验证标签搜索功能

**前置条件**:
- 系统中已有商品和标签

**测试步骤**:
```bash
# 单标签搜索
curl -X GET "http://localhost:8080/v1/products/tags/search?tags=维生素&page=1&size=10"

# 多标签搜索（AND关系）
curl -X GET "http://localhost:8080/v1/products/tags/search?tags=维生素&tags=增强免疫力&page=1&size=10"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://localhost:8080/v1/static/product/cover/...",
        "price": 59.90,
        "stock": 100,
        "tags": ["维生素", "增强免疫力", "抗氧化"]
      },
      {
        "id": 3,
        "title": "复合维生素片",
        "coverUrl": "http://localhost:8080/v1/static/product/cover/...",
        "price": 89.00,
        "stock": 50,
        "tags": ["维生素", "增强免疫力"]
      }
    ],
    "total": 15
  }
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] 返回的商品都包含搜索的标签
- [ ] 返回的商品包含tags字段
- [ ] 分页参数生效
- [ ] total字段正确

---

### 测试7：添加商品时自动生成标签

**测试ID**: TC-007
**优先级**: 🟢 中
**接口**: `POST /v1/merchant/products`

**测试目的**: 验证商品添加时自动调用AI生成标签

**前置条件**:
- 已登录获取token
- AI服务正常运行

**测试步骤**:
```bash
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {token}" \
  -F "title=测试商品-自动标签" \
  -F "category=HEALTH_PRODUCTS" \
  -F "price=99.00" \
  -F "stock=100" \
  -F "description=这是一款优质的维生素产品，能够增强免疫力" \
  -F "coverImage=@test.jpg"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 231,
    "title": "测试商品-自动标签",
    "tags": ["维生素", "增强免疫力", "优质产品"],
    ...
  }
}
```

**验证点**:
- [ ] 商品创建成功
- [ ] features字段包含标签数组
- [ ] need_regenerate_tags=false
- [ ] 后端日志显示"商品标签自动生成成功"

**后端日志验证**:
```bash
docker logs mall-backend | grep "商品标签自动生成成功"
```

**预期输出**:
```
商品标签自动生成成功: productId=231, tags=[维生素, 增强免疫力, 优质产品]
```

---

### 测试8：更新商品时标记需要重新生成

**测试ID**: TC-008
**优先级**: 🟢 中
**接口**: `PUT /v1/merchant/products/{id}`

**测试目的**: 验证标题/描述修改时标记重新生成

**前置条件**:
- 已登录获取token
- 存在商品ID

**测试步骤**:
```bash
# 1. 修改标题（应该标记need_regenerate_tags=1）
curl -X PUT http://localhost:8080/v1/merchant/products/1 \
  -H "Authorization: Bearer {token}" \
  -F "title=修改后的商品标题" \
  -F "category=HEALTH_PRODUCTS" \
  -F "price=99.00" \
  -F "stock=100" \
  -F "description=测试商品描述"

# 2. 查询商品，验证need_regenerate_tags状态
curl -X GET http://localhost:8080/v1/products/1
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "title": "修改后的商品标题",
    "needRegenerateTags": true,
    ...
  }
}
```

**验证点**:
- [ ] 商品更新成功
- [ ] needRegenerateTags字段为true
- [ ] 后端日志显示"商品标题或描述已修改，标记需要重新生成标签"

**后端日志验证**:
```bash
docker logs mall-backend | grep "标记需要重新生成标签"
```

**预期输出**:
```
商品标题或描述已修改，标记需要重新生成标签: productId=1
```

---

### 测试9：商品详情返回tags

**测试ID**: TC-009
**优先级**: 🟢 中
**接口**: `GET /v1/products/{id}`

**测试目的**: 验证商品详情API返回tags字段

**前置条件**:
- 商品已有标签

**测试步骤**:
```bash
curl -X GET http://localhost:8080/v1/products/1
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "merchantId": 4,
    "title": "天然维C片500mg",
    "category": "HEALTH_PRODUCTS",
    "description": "富含维生素 C，增强免疫力",
    "coverUrl": "http://localhost:8080/v1/static/product/cover/...",
    "price": 59.90,
    "stock": 100,
    "sales": 0,
    "averageRating": 4.5,
    "reviewCount": 10,
    "status": "ON_SALE",
    "tags": ["维生素", "增强免疫力", "抗氧化"],
    "detailImages": [...]
  }
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] data中包含tags字段
- [ ] tags字段为字符串数组
- [ ] tags内容正确

---

### 测试10：商品列表返回tags

**测试ID**: TC-010
**优先级**: 🟢 中
**接口**: `GET /v1/products`

**测试目的**: 验证商品列表API返回tags字段

**前置条件**:
- 系统中已有商品和标签

**测试步骤**:
```bash
curl -X GET "http://localhost:8080/v1/products?page=1&size=10"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://localhost:8080/v1/static/product/cover/...",
        "price": 59.90,
        "stock": 100,
        "tags": ["维生素", "增强免疫力", "抗氧化"]
      },
      {
        "id": 2,
        "title": "复合维生素片",
        "coverUrl": "http://localhost:8080/v1/static/product/cover/...",
        "price": 89.00,
        "stock": 50,
        "tags": ["维生素", "增强免疫力"]
      }
    ],
    "total": 230
  }
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] list中每个商品都包含tags字段
- [ ] tags字段为字符串数组

---

### 测试11：定时任务自动处理

**测试ID**: TC-011
**优先级**: 🔵 低
**测试目的**: 验证定时任务自动处理need_regenerate_tags=true的商品

**前置条件**:
- 定时任务已启用（product.tag.task.enabled=true）
- 有商品need_regenerate_tags=true

**测试步骤**:
```bash
# 1. 手动将某个商品的need_regenerate_tags设置为1
docker exec mall-mysql bash -c "mysql -uroot -proot123456 health_mall_system -e \"UPDATE products SET need_regenerate_tags = 1 WHERE id = 1\""

# 2. 等待定时任务执行（默认2小时）
# 或者手动触发定时任务（重启后端）
docker restart mall-backend

# 3. 查询该商品的tags是否已更新
curl -X GET http://localhost:8080/v1/products/tags/1
```

**验证点**:
- [ ] 定时任务日志显示处理记录
- [ ] need_regenerate_tags重置为false
- [ ] tags已更新

**后端日志验证**:
```bash
docker logs mall-backend | grep "商品标签重新生成成功"
```

**预期输出**:
```
开始执行商品标签重新生成定时任务，批次大小：50
商品标签重新生成成功: productId=1, tags=[维生素, 增强免疫力, 抗氧化]
需要重新生成标签的商品处理完成，成功1个
```

---

### 测试12：AI服务不可用时的降级处理

**测试ID**: TC-012
**优先级**: 🔵 低
**接口**: `POST /v1/products/tags/{productId}/generate`

**测试目的**: 验证AI服务不可用时的降级处理

**前置条件**:
- 停止AI服务
- 已登录获取token

**测试步骤**:
```bash
# 1. 停止AI服务
docker stop ai-service

# 2. 尝试生成标签
curl -X POST http://localhost:8080/v1/products/tags/1/generate \
  -H "Authorization: Bearer {token}"

# 3. 重启AI服务
docker start ai-service
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": []
}
```

**验证点**:
- [ ] API返回200状态码（不影响业务）
- [ ] 返回空数组
- [ ] 后端日志显示警告信息
- [ ] 商品创建/更新流程不受影响

**后端日志验证**:
```bash
docker logs mall-backend | grep "标签生成失败"
```

**预期输出**:
```
商品标签自动生成失败，但不影响商品创建: productId=1, error=Connection refused
```

---

### 测试13：空标签处理

**测试ID**: TC-013
**优先级**: 🔵 低
**接口**: `GET /v1/products/tags/{productId}`

**测试目的**: 验证没有标签的商品返回空数组

**前置条件**:
- 商品没有生成过标签

**测试步骤**:
```bash
# 创建一个新商品但不生成标签
curl -X POST http://localhost:8080/v1/merchant/products \
  -H "Authorization: Bearer {token}" \
  -F "title=无标签商品" \
  -F "category=HEALTH_PRODUCTS" \
  -F "price=99.00" \
  -F "stock=100" \
  -F "description=测试描述" \
  -F "coverImage=@test.jpg"

# 手动设置need_regenerate_tags=false
docker exec mall-mysql bash -c "mysql -uroot -proot123456 health_mall_system -e \"UPDATE products SET need_regenerate_tags = 0, features = NULL WHERE id = (SELECT MAX(id) FROM products)\""

# 查询标签
curl -X GET "http://localhost:8080/v1/products/tags/{new_product_id}"
```

**预期结果**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": []
}
```

**验证点**:
- [ ] API返回200状态码
- [ ] data为空数组
- [ ] 不会报错

---

### 测试14：权限验证

**测试ID**: TC-014
**优先级**: 🔵 低
**接口**: `PUT /v1/products/tags/{productId}`

**测试目的**: 验证只有商品所有者可以修改标签

**前置条件**:
- 使用非商品所有者的账号登录

**测试步骤**:
```bash
# 1. 使用testmerchant1登录（商品所有者）
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testmerchant1","password":"Test123456"}'

# 2. 使用testmerchant2登录（非所有者）
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testmerchant2","password":"Test123456"}'

# 3. 使用testmerchant2的token尝试修改testmerchant1的商品标签
curl -X PUT http://localhost:8080/v1/products/tags/1 \
  -H "Authorization: Bearer {testmerchant2_token}" \
  -H "Content-Type: application/json" \
  -d '{"tags": ["测试标签"]}'
```

**预期结果**:
```json
{
  "code": 403,
  "msg": "无权修改此商品",
  "data": null
}
```

**验证点**:
- [ ] API返回403状态码
- [ ] 错误信息明确
- [ ] 标签未被修改

---

## 测试执行计划

### 阶段1：基础功能测试（优先级：高）
- [ ] TC-001: 为商品生成标签
- [ ] TC-002: 获取商品标签
- [ ] TC-003: 手动更新商品标签

### 阶段2：批量功能测试（优先级：中）
- [ ] TC-004: 批量生成商品标签
- [ ] TC-005: 获取热门标签
- [ ] TC-006: 按标签搜索商品

### 阶段3：集成功能测试（优先级：中）
- [ ] TC-007: 添加商品时自动生成标签
- [ ] TC-008: 更新商品时标记需要重新生成
- [ ] TC-009: 商品详情返回tags
- [ ] TC-010: 商品列表返回tags

### 阶段4：高级功能测试（优先级：低）
- [ ] TC-011: 定时任务自动处理
- [ ] TC-012: AI服务不可用时的降级处理
- [ ] TC-013: 空标签处理
- [ ] TC-014: 权限验证

---

## 快速测试脚本

### 一键执行所有测试

```bash
#!/bin/bash

# 配置
BACKEND_URL="http://localhost:8080"
USERNAME="testmerchant1"
PASSWORD="Test123456"

# 获取token
echo "=== 获取Token ==="
TOKEN=$(curl -s -X POST ${BACKEND_URL}/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}" \
  | jq -r '.data.token')

echo "Token: ${TOKEN}"

# 测试1：为商品生成标签
echo "=== TC-001: 为商品生成标签 ==="
curl -X POST ${BACKEND_URL}/v1/products/tags/1/generate \
  -H "Authorization: Bearer ${TOKEN}" \
  | jq '.'

# 测试2：获取商品标签
echo "=== TC-002: 获取商品标签 ==="
curl -X GET ${BACKEND_URL}/v1/products/tags/1 \
  | jq '.'

# 测试3：手动更新商品标签
echo "=== TC-003: 手动更新商品标签 ==="
curl -X PUT ${BACKEND_URL}/v1/products/tags/1 \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"tags": ["维生素", "增强免疫力", "抗氧化", "天然原料", "新品推荐"]}' \
  | jq '.'

# 测试4：批量生成商品标签
echo "=== TC-004: 批量生成商品标签 ==="
curl -X POST ${BACKEND_URL}/v1/products/tags/batch/generate \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"productIds": [1, 2, 3, 4, 5]}' \
  | jq '.'

# 测试5：获取热门标签
echo "=== TC-005: 获取热门标签 ==="
curl -X GET "${BACKEND_URL}/v1/products/tags/popular?limit=10" \
  | jq '.'

# 测试6：按标签搜索商品
echo "=== TC-006: 按标签搜索商品 ==="
curl -X GET "${BACKEND_URL}/v1/products/tags/search?tags=维生素&tags=增强免疫力&page=1&size=10" \
  | jq '.'

echo "=== 所有测试完成 ==="
```

### 单独测试命令

```bash
# 获取token
TOKEN=$(curl -s -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testmerchant1","password":"Test123456"}' \
  | jq -r '.data.token')

# 测试1
curl -X POST http://localhost:8080/v1/products/tags/1/generate \
  -H "Authorization: Bearer $TOKEN"

# 测试2
curl -X GET http://localhost:8080/v1/products/tags/1

# 测试3
curl -X PUT http://localhost:8080/v1/products/tags/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tags": ["维生素", "增强免疫力", "抗氧化"]}'

# 测试4
curl -X POST http://localhost:8080/v1/products/tags/batch/generate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productIds": [1, 2, 3, 4, 5]}'

# 测试5
curl -X GET "http://localhost:8080/v1/products/tags/popular?limit=10"

# 测试6
curl -X GET "http://localhost:8080/v1/products/tags/search?tags=维生素&page=1&size=10"
```

---

## 测试报告模板

### 测试执行记录

| 测试ID | 测试名称 | 执行时间 | 执行人 | 结果 | 备注 |
|---------|---------|---------|--------|------|------|
| TC-001 | 为商品生成标签 | | | |
| TC-002 | 获取商品标签 | | | |
| TC-003 | 手动更新商品标签 | | | |
| TC-004 | 批量生成商品标签 | | | |
| TC-005 | 获取热门标签 | | | |
| TC-006 | 按标签搜索商品 | | | |
| TC-007 | 添加商品时自动生成标签 | | | |
| TC-008 | 更新商品时标记需要重新生成 | | | |
| TC-009 | 商品详情返回tags | | | |
| TC-010 | 商品列表返回tags | | | |
| TC-011 | 定时任务自动处理 | | | |
| TC-012 | AI服务不可用时的降级处理 | | | |
| TC-013 | 空标签处理 | | | |
| TC-014 | 权限验证 | | | |

### 测试结果统计

- **总测试数**: 14
- **通过数**: __
- **失败数**: __
- **通过率**: __%

### 问题记录

| 问题ID | 问题描述 | 严重程度 | 状态 | 解决方案 |
|--------|---------|---------|------|--------|
| | | | |

---

## 附录

### A. 数据库表结构

```sql
CREATE TABLE `products` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `merchant_id` INT,
  `title` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50),
  `description` TEXT,
  `cover_url` VARCHAR(255) NOT NULL,
  `features` JSON COMMENT '商品标签（JSON数组格式）',
  `price` DECIMAL(10,2) NOT NULL,
  `stock` INT,
  `sales` INT DEFAULT 0,
  `average_rating` DECIMAL(3,2) DEFAULT 0.00,
  `review_count` INT DEFAULT 0,
  `status` ENUM('ON_SALE','OFF_SALE','OUT_OF_STOCK') DEFAULT 'ON_SALE',
  `auto_confirm_mode` ENUM('AUTO','MANUAL','SMART') DEFAULT 'MANUAL',
  `auto_confirm_condition` TEXT,
  `need_regenerate_tags` TINYINT(1) DEFAULT 0 COMMENT '是否需要重新生成标签',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_need_regenerate_tags` (`need_regenerate_tags`)
);
```

### B. AI服务接口规范

```python
# POST /api/generate-tags
# Content-Type: application/json

{
  "prompt": "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：天然维C片500mg\n商品描述：富含维生素 C，增强免疫力，抗氧化\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]"
}

Response:
{
  "tags": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

### C. 常见错误码

| 错误码 | 说明 | 解决方案 |
|---------|------|---------|
| 400 | 请求参数错误 | 检查请求体格式 |
| 401 | 未授权 | 检查token是否有效 |
| 403 | 权限不足 | 检查是否为商品所有者 |
| 404 | 资源不存在 | 检查商品ID是否正确 |
| 500 | 服务器内部错误 | 查看后端日志 |

---

**测试文档版本**: v1.0  
**创建日期**: 2026-03-04  
**最后更新**: 2026-03-04
