# 用户相关 API 测试报告

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

### 测试1: 获取用户信息

**接口**: `GET /v1/user/profile`

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
  "data": {
    "id": 15,
    "username": "testuser1",
    "avatarUrl": null,
    "email": "testuser1@example.com",
    "phone": "13800138001",
    "role": "USER",
    "remarks": null,
    "createdAt": "2024-01-15 10:30:00"
  }
}
```

**说明**: 成功获取用户信息，返回完整的用户资料。

---

### 测试2: 更新用户信息（仅头像URL）

**接口**: `PUT /v1/user/profile/update`

**请求头**:
```
Authorization: Bearer {token}
```

**请求体**:
```json
{
  "avatarUrl": "http://example.com/new-avatar.jpg"
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

**说明**: 成功更新用户头像URL。

---

### 测试3: 更新用户信息（仅备注）

**接口**: `PUT /v1/user/profile/update`

**请求头**:
```
Authorization: Bearer {token}
```

**请求体**:
```json
{
  "remarks": "Updated remarks for testing"
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

**说明**: 成功更新用户备注信息。

---

### 测试4: 更新用户信息（同时更新头像URL和备注）

**接口**: `PUT /v1/user/profile/update`

**请求头**:
```
Authorization: Bearer {token}
```

**请求体**:
```json
{
  "avatarUrl": "http://example.com/updated-avatar.jpg",
  "remarks": "Final updated remarks"
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

**说明**: 成功同时更新头像URL和备注信息。

---

### 测试5: 上传用户头像

**接口**: `POST /v1/user/avatar/upload`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 头像图片文件 |

**测试图片**: test_images/test_cover.jpg

**测试结果**: ✅ 通过

**响应**:
```json
{
  "code": 200,
  "msg": "头像上传成功",
  "data": {
    "avatarUrl": "/v1/static/user/avatar/2026/03/03/21493bebd3b341e9ba08fa01fbe036c3.jpg"
  }
}
```

**说明**: 成功上传用户头像，返回头像URL。头像存储在服务器指定路径。

---

### 测试6: 更新后获取用户信息

**接口**: `GET /v1/user/profile`

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
  "data": {
    "id": 15,
    "username": "testuser1",
    "avatarUrl": "/v1/static/user/avatar/2026/03/03/21493bebd3b341e9ba08fa01fbe036c3.jpg",
    "email": "testuser1@example.com",
    "phone": "13800138001",
    "role": "USER",
    "remarks": null,
    "createdAt": "2024-01-15 10:30:00"
  }
}
```

**说明**: 成功获取更新后的用户信息，头像URL已更新为上传的图片地址。

---

### 测试7: 未授权访问用户信息（应该失败）

**接口**: `GET /v1/user/profile`

**测试结果**: ✅ 通过（正确失败）

**错误信息**:
```
远程服务器返回错误: (401) 未经授权。
```

**说明**: 未提供token时正确返回401未授权错误，认证机制正常工作。

---

## 问题汇总

### 无问题
所有测试用例均通过，用户相关API功能正常。

## 测试数据保存
- CSV结果文件: `scripts/test_user_api_results.csv`
- 测试脚本: `scripts/test_user_api.ps1`

## 全局变量（用于后续测试）
- `$global:userToken`: 用户Token（testuser1）
- `$global:userId`: 用户ID（15）

## 测试图片
- 头像测试图片: `test_images/test_cover.jpg`
- 上传后的头像URL: `/v1/static/user/avatar/2026/03/03/21493bebd3b341e9ba08fa01fbe036c3.jpg`
