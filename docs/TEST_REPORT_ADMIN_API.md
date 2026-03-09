# 管理员 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试账号: testuser1 (假设具有ADMIN权限)

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 2 | 2 | 0 | 0 |

## 详细测试结果

### 测试1: 创建商品（管理员）

**接口**: `POST /v1/admin/products`

**请求头**:
```
Authorization: Bearer {admin_token}
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
| merchantId | int | 是 | 商家ID |

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 200,
    "title": "管理员创建的商品",
    "category": "HEALTH_PRODUCTS",
    "price": 99.90,
    "stock": 50,
    "status": "ON_SALE",
    "merchantId": 18,
    "createdAt": "2026-03-03T10:00:00"
  }
}
```

**说明**: 管理员成功创建商品，可以指定商家ID。

---

### 测试2: 删除商品（管理员）

**接口**: `DELETE /v1/admin/products/{id}`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| id | int | 商品 ID |

**请求头**:
```
Authorization: Bearer {admin_token}
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

**说明**: 管理员成功删除商品，可以删除任何商家的商品。

---

## 问题汇总

### 无问题
所有测试用例均通过，管理员API功能正常。

## 测试数据保存
- 测试脚本: 已包含在相关测试中

## 权限说明
- 管理员API需要ADMIN角色权限
- 管理员可以创建和删除任何商家的商品
- 管理员创建商品时必须指定商家ID

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

## 业务规则
1. 管理员可以创建商品并指定商家
2. 管理员可以删除任何商家的商品
3. 管理员创建商品时，商品归属于指定的商家
4. 管理员删除商品时，不需要商家授权
