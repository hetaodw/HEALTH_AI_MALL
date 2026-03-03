# 地址管理 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testuser1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 7 | 7 | 0 | 0 |

## 详细测试结果

### 测试1: 获取用户地址列表

**接口**: `GET /v1/addresses`

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
  "data": [
    {
      "id": 1,
      "userId": 15,
      "receiverName": "张三",
      "receiverPhone": "13800138000",
      "province": "广东省",
      "city": "深圳市",
      "district": "南山区",
      "detailAddress": "科技园",
      "isDefault": true,
      "createdAt": "2026-03-03T10:00:00"
    }
  ]
}
```

**说明**: 成功获取用户地址列表。

---

### 测试2: 获取默认地址

**接口**: `GET /v1/addresses/default`

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
    "userId": 15,
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "province": "广东省",
    "city": "深圳市",
    "district": "南山区",
    "detailAddress": "科技园",
    "isDefault": true,
    "createdAt": "2026-03-03T10:00:00"
  }
}
```

**说明**: 成功获取用户默认地址。

---

### 测试3: 获取地址详情

**接口**: `GET /v1/addresses/{addressId}`

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
    "userId": 15,
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "province": "广东省",
    "city": "深圳市",
    "district": "南山区",
    "detailAddress": "科技园",
    "isDefault": true,
    "createdAt": "2026-03-03T10:00:00"
  }
}
```

**说明**: 成功获取指定地址的详细信息。

---

### 测试4: 创建地址

**接口**: `POST /v1/addresses`

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "receiverName": "李四",
  "receiverPhone": "13800138001",
  "province": "广东省",
  "city": "深圳市",
  "district": "福田区",
  "detailAddress": "华强北",
  "isDefault": false
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| receiverName | string | 是 | 收货人姓名 |
| receiverPhone | string | 是 | 收货人电话 |
| province | string | 是 | 省份 |
| city | string | 是 | 城市 |
| district | string | 是 | 区县 |
| detailAddress | string | 是 | 详细地址 |
| isDefault | boolean | 否 | 是否默认地址，默认false |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 2,
    "userId": 15,
    "receiverName": "李四",
    "receiverPhone": "13800138001",
    "province": "广东省",
    "city": "深圳市",
    "district": "福田区",
    "detailAddress": "华强北",
    "isDefault": false,
    "createdAt": "2026-03-03T10:05:00"
  }
}
```

**说明**: 成功创建新地址。

---

### 测试5: 更新地址

**接口**: `PUT /v1/addresses/{addressId}`

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "receiverName": "李四（更新）",
  "receiverPhone": "13800138001",
  "province": "广东省",
  "city": "深圳市",
  "district": "福田区",
  "detailAddress": "华强北电子市场",
  "isDefault": false
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
    "userId": 15,
    "receiverName": "李四（更新）",
    "receiverPhone": "13800138001",
    "province": "广东省",
    "city": "深圳市",
    "district": "福田区",
    "detailAddress": "华强北电子市场",
    "isDefault": false,
    "createdAt": "2026-03-03T10:05:00"
  }
}
```

**说明**: 成功更新地址信息。

---

### 测试6: 设置默认地址

**接口**: `PUT /v1/addresses/{addressId}/default`

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
  "data": null
}
```

**说明**: 成功设置默认地址，其他地址的isDefault字段自动更新为false。

---

### 测试7: 删除地址

**接口**: `DELETE /v1/addresses/{addressId}`

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
  "data": null
}
```

**说明**: 成功删除地址。

---

## 问题汇总

### 无问题
所有测试用例均通过，地址管理API功能正常。

## 测试数据保存
- 测试脚本: 已包含在相关测试中

## 地址字段说明
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 地址ID |
| userId | int | 用户ID |
| receiverName | string | 收货人姓名 |
| receiverPhone | string | 收货人电话 |
| province | string | 省份 |
| city | string | 城市 |
| district | string | 区县 |
| detailAddress | string | 详细地址 |
| isDefault | boolean | 是否默认地址 |
| createdAt | datetime | 创建时间 |

## 业务规则
1. 一个用户只能有一个默认地址
2. 设置新默认地址时，其他地址自动更新为非默认
3. 删除默认地址时，系统会自动设置其他地址为默认
4. 删除最后一个地址时，需要重新创建地址
