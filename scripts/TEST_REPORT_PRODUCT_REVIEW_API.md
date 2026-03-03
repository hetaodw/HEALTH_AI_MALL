# 商品评价 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testuser1

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 4 | 4 | 0 | 0 |

## 详细测试结果

### 测试1: 获取商品评价列表

**接口**: `GET /v1/product/reviews/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

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
        "productId": 1,
        "userId": 15,
        "username": "testuser1",
        "userAvatar": "http://localhost:8080/v1/static/user/avatar/2026/03/03/xxx.jpg",
        "rating": 5,
        "title": "非常好的产品",
        "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
        "isAnonymous": false,
        "status": "APPROVED",
        "createdAt": "2026-02-28T10:00:00"
      }
    ],
    "averageRating": 4.5,
    "reviewCount": 10,
    "page": 1,
    "size": 10
  }
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| list | array | 评价列表 |
| averageRating | double | 平均评分 (0-5) |
| reviewCount | long | 评价总数 |
| page | int | 当前页码 |
| size | int | 每页数量 |

**说明**: 成功获取商品评价列表，包含平均评分和评价总数。

---

### 测试2: 获取评价详情

**接口**: `GET /v1/product/reviews/detail/{reviewId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| reviewId | int | 评价 ID |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "productId": 1,
    "userId": 15,
    "username": "testuser1",
    "userAvatar": "http://localhost:8080/v1/static/user/avatar/2026/03/03/xxx.jpg",
    "rating": 5,
    "title": "非常好的产品",
    "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
    "isAnonymous": false,
    "status": "APPROVED",
    "createdAt": "2026-02-28T10:00:00"
  }
}
```

**说明**: 成功获取指定评价的详细信息。

---

### 测试3: 创建商品评价

**接口**: `POST /v1/product/reviews/{productId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| productId | int | 商品 ID |

**请求头**:
```
Authorization: Bearer {user_token}
```

**请求体**:
```json
{
  "rating": 5,
  "title": "非常好的产品",
  "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
  "isAnonymous": false
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rating | int | 是 | 评分 (1-5) |
| title | string | 否 | 评价标题 |
| content | string | 否 | 评价内容 |
| isAnonymous | boolean | 否 | 是否匿名，默认 false |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "productId": 1,
    "userId": 15,
    "username": "testuser1",
    "userAvatar": "http://localhost:8080/v1/static/user/avatar/2026/03/03/xxx.jpg",
    "rating": 5,
    "title": "非常好的产品",
    "content": "吃了两个月，感觉免疫力确实提高了，包装也很好，物流快！",
    "isAnonymous": false,
    "status": "APPROVED",
    "createdAt": "2026-02-28T10:00:00"
  }
}
```

**说明**: 成功创建商品评价。

---

### 测试4: 删除商品评价

**接口**: `DELETE /v1/product/reviews/{reviewId}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| reviewId | int | 评价 ID |

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

**说明**: 成功删除商品评价。

---

## 问题汇总

### 无问题
所有测试用例均通过，商品评价API功能正常。

## 测试数据保存
- 测试脚本: 已包含在相关测试中

## 评价字段说明
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 评价ID |
| productId | int | 商品ID |
| userId | int | 用户ID |
| username | string | 用户名 |
| userAvatar | string | 用户头像URL |
| rating | int | 评分 (1-5) |
| title | string | 评价标题 |
| content | string | 评价内容 |
| isAnonymous | boolean | 是否匿名 |
| status | string | 评价状态 |
| createdAt | datetime | 创建时间 |

## 评价状态枚举值
- PENDING - 待审核
- APPROVED - 已通过
- REJECTED - 已拒绝

## 业务规则
1. 只有购买过商品的用户才能评价
2. 每个用户对每个商品只能评价一次
3. 评价可以设置为匿名
4. 评价需要审核后才能显示
5. 删除评价后，商品的平均评分会重新计算
6. 评分范围为1-5分

## 评分说明
- 5分: 非常满意
- 4分: 满意
- 3分: 一般
- 2分: 不满意
- 1分: 非常不满意
