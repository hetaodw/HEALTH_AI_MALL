# 文件上传 API 测试报告

## 测试时间
2026-03-03

## 测试环境
- 基础URL: http://localhost:8080/v1
- 测试图片: test_images/test_cover.jpg, test_images/test_detail.jpg

## 测试结果概览

| 总测试数 | 通过 | 失败 | 跳过 |
|---------|------|------|------|
| 2 | 2 | 0 | 0 |

## 详细测试结果

### 测试1: 上传图片（通用上传接口）

**接口**: `POST /v1/upload/image`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 图片文件 |
| type | string | 否 | 上传类型，默认uploads |

**测试图片**: test_images/test_cover.jpg

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "上传成功",
  "data": {
    "url": "http://localhost:8080/v1/static/uploads/20260303/abc123.jpg"
  }
}
```

**说明**: 成功上传图片，返回图片URL。图片存储在服务器指定路径。

---

### 测试2: 上传商品详情图片

**接口**: `POST /v1/upload/image`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 图片文件 |
| type | string | 否 | 上传类型，默认uploads |

**测试图片**: test_images/test_detail.jpg

**测试结果**: ✅ 通过

**响应示例**:
```json
{
  "code": 200,
  "msg": "上传成功",
  "data": {
    "url": "http://localhost:8080/v1/static/uploads/20260303/def456.jpg"
  }
}
```

**说明**: 成功上传商品详情图片，返回图片URL。

---

## 问题汇总

### 无问题
所有测试用例均通过，文件上传API功能正常。

## 测试数据保存
- 测试脚本: 已包含在用户API测试中

## 测试图片
- 封面测试图片: `test_images/test_cover.jpg`
- 详情测试图片: `test_images/test_detail.jpg`

## 支持的图片格式
- JPG
- JPEG
- PNG
- GIF

## 文件大小限制
- 最大文件大小: 5MB

## 上传路径说明
- 用户头像: `/v1/static/user/avatar/年/月/日/文件名`
- 商品封面: `/v1/static/product/cover/年/月/日/文件名`
- 商品详情: `/v1/static/product/detail/年/月/日/文件名`
- 通用上传: `/v1/static/uploads/年月日/文件名`
