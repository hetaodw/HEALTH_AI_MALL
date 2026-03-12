# 认证相关 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testuser1, testmerchant1

## 测试结果概览

| 总测试数 | 通过 | 失败 |
|---------|------|------|
| 7 | 5 | 2 |

## 详细测试结果

### 测试1: 用户注册

**接口**: `POST /v1/auth/register`

**测试数据**:
```json
{
  "username": "testuser_20260303232928",
  "password": "Test123456",
  "avatarUrl": "http://example.com/avatar.jpg",
  "email": "testuser_20260303232928@example.com",
  "phone": "13800138000",
  "role": "USER",
  "remarks": "Test User"
}
```

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**说明**: 用户注册成功，返回200状态码。

---

### 测试2: 重复注册（应该失败）

**接口**: `POST /v1/auth/register`

**测试数据**: 与测试1相同的用户名

**测试结果**: ❌ 失败

**问题描述**: 重复注册应该失败但成功了

**说明**: 后端未实现用户名唯一性验证，存在安全隐患。

---

### 测试3: 用户登录

**接口**: `POST /v1/auth/login`

**测试数据**:
```json
{
  "username": "testuser_20260303232928",
  "password": "Test123456"
}
```

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiIyMSIsInVzZXJuYW1lI...",
    "userInfo": {
      "id": 21,
      "username": "testuser_20260303232928",
      "avatarUrl": "http://example.com/avatar.jpg",
      "email": "testuser_20260303232928@example.com",
      "phone": "13800138000",
      "role": "USER"
    }
  }
}
```

**说明**: 登录成功，返回JWT token和用户信息。

---

### 测试4: 错误密码登录（应该失败）

**接口**: `POST /v1/auth/login`

**测试数据**:
```json
{
  "username": "testuser_20260303232928",
  "password": "WrongPassword123"
}
```

**测试结果**: ❌ 失败

**问题描述**: 错误密码登录应该失败但成功了

**说明**: 后端未正确实现密码验证逻辑，存在严重安全隐患。

---

### 测试5: 用户登出

**接口**: `POST /v1/auth/logout`

**请求头**:
```
Authorization: Bearer {token}
```

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**说明**: 用户登出成功。

---

### 测试6: 已注册账号登录（testuser1）

**接口**: `POST /v1/auth/login`

**测试数据**:
```json
{
  "username": "testuser1",
  "password": "Test123456"
}
```

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiIxNSIsInVzZXJuYW1lI...",
    "userInfo": {
      "id": 15,
      "username": "testuser1",
      "avatarUrl": null,
      "email": "testuser1@example.com",
      "phone": "13800138001",
      "role": "USER"
    }
  }
}
```

**说明**: 已注册账号登录成功，Token已保存到全局变量 `$global:userToken`，用户ID: 15。

---

### 测试7: 商家账号登录（testmerchant1）

**接口**: `POST /v1/auth/login`

**测试数据**:
```json
{
  "username": "testmerchant1",
  "password": "Test123456"
}
```

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiIxOCIsInVzZXJuYW1lI...",
    "userInfo": {
      "id": 18,
      "username": "testmerchant1",
      "avatarUrl": null,
      "email": "testmerchant1@example.com",
      "phone": "13800138004",
      "role": "MERCHANT"
    }
  }
}
```

**说明**: 商家账号登录成功，Token已保存到全局变量 `$global:merchantToken`，用户ID: 18。

---

## 问题汇总

### 严重问题
1. **重复注册未验证**: 后端未实现用户名唯一性验证，允许重复注册相同用户名
2. **密码验证失效**: 错误密码登录仍然成功，密码验证逻辑存在严重问题

### 建议
1. 在注册接口添加用户名唯一性检查
2. 检查密码加密和验证逻辑
3. 添加更多的输入验证和安全检查

## 测试数据保存
- CSV结果文件: `scripts/test_auth_api_results.csv`
- 测试脚本: `scripts/test_auth_api.ps1`

## 全局变量（用于后续测试）
- `$global:userToken`: 用户Token（testuser1）
- `$global:userId`: 用户ID（15）
- `$global:merchantToken`: 商家Token（testmerchant1）
- `$global:merchantId`: 商家ID（18）
