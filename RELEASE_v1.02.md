# 健康商城系统 v1.02 发布报告

**发布日期**: 2026-01-30  
**版本号**: v1.02  
**Git标签**: `v1.02`  
**提交ID**: `953b14f`

---

## 更新摘要

本次更新主要修复了商品详情图片上传和商品详情获取的相关问题，同时新增了订单管理功能。

---

## 主要修复内容

### 1. 商品详情图片上传功能修复 ✅

**问题描述**:
- 上传商品详情图片后刷新页面，图片消失
- 编辑商品时，原有详情图片无法正确加载和保存

**修复内容**:
- **后端**: `MerchantProductController.java`
  - 新增 `existingDetailImages` 参数支持，用于接收已存在的图片URL
  - 修复更新商品时合并已有图片和新上传图片的逻辑

- **后端**: `MerchantProductService.java`
  - 修复 `updateProduct` 方法中 `coverUrl` 为 null 时导致的数据库更新失败问题
  - 添加空值检查，只在传入新值时才更新字段

- **前端**: `ProductForm.vue`
  - 修复编辑商品时详情图片加载逻辑，正确显示已有图片
  - 分离已有图片URL和新上传文件，分别传递给后端

- **前端**: `api/index.js`
  - 修复 FormData 上传时的 Content-Type 设置问题
  - 移除手动设置的 `multipart/form-data`，让浏览器自动设置 boundary

### 2. 商品详情获取功能修复 ✅

**问题描述**:
- 点击商品详情页面时获取数据失败

**修复内容**:
- **前端**: `ProductDetail.vue`
  - 修复 API 响应处理逻辑
  - 使用正确的 API 方法 `api.products.getDetail()`
  - 正确处理响应数据格式

### 3. 新增订单管理功能 🆕

**新增文件**:
- `OrderController.java` - 订单控制器
- `OrderService.java` - 订单服务层
- `Order.java` - 订单实体类
- `OrderRepository.java` - 订单数据访问层
- `CreateOrderRequest.java` - 创建订单请求DTO
- `OrderResponse.java` - 订单响应DTO

**功能特性**:
- 创建订单
- 查询我的订单列表
- 查询订单详情
- 取消订单

---

## 文件变更列表

### 后端变更 (Backend)
```
backend/src/main/java/com/healthmall/controller/MerchantProductController.java
backend/src/main/java/com/healthmall/service/MerchantProductService.java
backend/src/main/java/com/healthmall/service/ProductService.java
backend/src/main/java/com/healthmall/dto/MerchantProductRequest.java
backend/src/main/java/com/healthmall/dto/MerchantProductResponse.java
backend/src/main/java/com/healthmall/dto/ProductDetailResponse.java
backend/src/main/java/com/healthmall/config/WebConfig.java
backend/src/main/resources/application.yml
backend/Dockerfile
```

### 前端变更 (Frontend)
```
frontend/src/views/ProductDetail.vue
frontend/src/views/MerchantDashboard.vue
frontend/src/components/ProductForm.vue
frontend/src/api/index.js
frontend/src/router/index.js
frontend/Dockerfile
```

### 配置变更
```
docker-compose.yml
docker-compose.override.yml
nginx/conf.d/default.conf
```

### 文档变更
```
docs/API_DOCUMENTATION.md (从根目录移动)
docs/database-schema.md (新增)
docs/startguide.md (新增)
README.md
```

---

## API 变更

### 修复的 API

#### 更新商品 (商家)
```
PUT /v1/merchant/products/{id}
```
**变更**:
- 新增参数 `existingDetailImages` - 已有详情图片URL列表
- 修复 `coverUrl` 为 null 时的更新问题

#### 获取商品详情
```
GET /v1/products/{id}
```
**修复**: 响应格式正确处理，返回完整的商品详情包括 `detailImages`

### 新增的 API

#### 订单相关
```
POST   /v1/orders              - 创建订单
GET    /v1/orders/my          - 查询我的订单列表
GET    /v1/orders/{id}        - 查询订单详情
POST   /v1/orders/{id}/cancel - 取消订单
```

---

## 测试验证

### 测试环境
- **数据库**: MySQL 8.0
- **缓存**: Redis 7
- **后端**: Spring Boot 3.2.0
- **前端**: Vue 3 + Vite

### 测试结果

#### 商品详情图片上传测试 ✅
```bash
# 测试命令
curl -X PUT "http://localhost:8080/v1/merchant/products/1" \
  -H "Authorization: Bearer {token}" \
  -F "title=test" \
  -F "category=保健品" \
  -F "price=999" \
  -F "stock=97" \
  -F "description=test" \
  -F "status=ON_SALE" \
  -F "detailImages=@/tmp/test_image.png"

# 响应结果
{"code":200,"msg":"操作成功","data":{...,"detailImages":["/v1/static/product/detail/2026/01/30/xxx.png"]}}
```

#### 数据库验证 ✅
```sql
SELECT * FROM product_details_images WHERE product_id = 1;
-- 结果: 图片记录正确保存到数据库
```

#### 商品详情获取测试 ✅
```bash
curl http://localhost:8080/v1/products/1
# 响应结果包含 detailImages 数组
```

---

## 部署说明

### 使用 Docker Compose 部署

```bash
# 拉取最新代码
git pull
git checkout v1.02

# 构建并启动服务
docker-compose down
docker-compose up -d --build
```

### 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| mall-nginx | 80 | 前端入口 |
| mall-backend | 8080 | 后端API |
| mall-mysql | 4000 | 数据库 |
| mall-redis | 6379 | 缓存 |
| mall-frontend | 3000 | 前端开发服务器 |

---

## 已知问题

无

---

## 后续计划

- v1.03: 优化前端UI交互体验
- v1.04: 添加支付功能
- v1.05: 添加商品搜索和筛选功能

---

## 贡献者

- 开发团队

---

**注意**: 本次更新涉及数据库结构变更，建议在部署前备份数据。
