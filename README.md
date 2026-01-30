## 系统部署说明

### 1. 环境要求
- Docker Desktop
- Docker Compose
- PowerShell (Windows) 或 Bash (Linux/Mac)

### 2. 代理配置

#### 2.1 主机代理设置（用于Docker下载镜像）
如果需要通过代理下载Docker镜像，请在主机上设置环境变量：

**PowerShell:**
```powershell
$env:HTTP_PROXY="http://127.0.0.1:7897"
$env:HTTPS_PROXY="http://127.0.0.1:7897"
```

**Bash:**
```bash
export HTTP_PROXY="http://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
```

#### 2.2 容器构建代理设置
已在 `docker-compose.override.yml` 中配置构建代理参数，使用 `host.docker.internal` 让容器访问主机的代理：

```yaml
services:
  mall-backend:
    build:
      args:
        - HTTP_PROXY=http://host.docker.internal:7897
        - HTTPS_PROXY=http://host.docker.internal:7897
  mall-frontend:
    build:
      args:
        - HTTP_PROXY=http://host.docker.internal:7897
        - HTTPS_PROXY=http://host.docker.internal:7897
```

**注意**: `host.docker.internal` 是Docker提供的特殊DNS名称，用于容器访问主机服务。在Windows和Mac上默认可用，Linux上需要Docker 20.10+版本。

### 3. 系统架构
1. 系统使用docker构建
2. 系统使用mysql数据库，数据库地址为mysql://mall-mysql:3306/health_mall_system，外部访问端口为4000，utf8mb4编码
3. 系统使用redis数据库，数据库地址为redis://mall-redis:6379/0
4. 系统使用nginx作为web服务器，nginx配置文件为/etc/nginx/nginx.conf
5. 系统将使用docker-compose.yml文件启动，启动时需要初始化数据库等

### 4. 快速启动

```powershell
# 设置代理（如需要）
$env:HTTP_PROXY="http://127.0.0.1:7897"
$env:HTTPS_PROXY="http://127.0.0.1:7897"

# 启动所有服务
docker-compose up -d

# 或只启动特定服务
docker-compose up -d mall-backend
docker-compose up -d mall-frontend
```

### 5. 重新构建服务

当代码修改后，需要重新构建容器：

```powershell
# 设置代理
$env:HTTP_PROXY="http://127.0.0.1:7897"
$env:HTTPS_PROXY="http://127.0.0.1:7897"

# 停止并删除容器
docker-compose stop mall-backend
docker-compose rm -f mall-backend

# 重新构建（不使用缓存）
docker-compose build --no-cache mall-backend

# 启动容器
docker-compose up -d mall-backend

# 查看日志
docker logs -f mall-backend
```

### 6. 服务端口

| 服务 | 容器端口 | 映射端口 | 说明 |
|------|----------|----------|------|
| mall-backend | 8080 | 8080 | 后端API服务 |
| mall-mysql | 3306 | 4000 | MySQL数据库 |
| mall-redis | 6379 | 6379 | Redis缓存 |
| mall-nginx | 80 | 80 | Nginx反向代理 |
| mall-frontend | 80 | 3000 | 前端服务 |

数据库部分:-- 创建数据库 (可选)
CREATE DATABASE IF NOT EXISTS health_mall DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE health_mall;

-- 1. 用户表

CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一标识',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '加密后的密码',
    `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT '用户头像地址',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱地址',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号码',
    `role` ENUM('USER', 'MERCHANT') DEFAULT 'USER' COMMENT '用户角色：USER-普通用户，MERCHANT-商家',
    `remarks` TEXT DEFAULT NULL COMMENT '备注信息',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE=InnoDB COMMENT='用户信息表';

-- 2. 商品表
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '商品唯一标识',
    `merchant_id` INT DEFAULT NULL COMMENT '商家ID',
    `title` VARCHAR(100) NOT NULL COMMENT '商品名称',
    `category` VARCHAR(50) DEFAULT NULL COMMENT '商品分类',
    `description` TEXT COMMENT '商品详细描述',
    `cover_url` VARCHAR(255) NOT NULL COMMENT '商品封面图片URL',
    `features` JSON DEFAULT NULL COMMENT '商品特征（暂时留空，使用JSON格式方便扩展）',
    `price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格',
    `stock` INT DEFAULT 0 COMMENT '库存',
    `sales` INT DEFAULT 0 COMMENT '销量',
    `status` ENUM('ON_SALE', 'OFF_SALE', 'OUT_OF_STOCK') DEFAULT 'ON_SALE' COMMENT '商品状态：ON_SALE-在售，OFF_SALE-下架（前端不展示），OUT_OF_STOCK-缺货',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`merchant_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='商品基础信息表';

-- 3. 商品详情图表 (用于存放多张商品详情介绍图)
CREATE TABLE `product_details_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL COMMENT '所属商品ID',
    `image_url` VARCHAR(255) NOT NULL COMMENT '详情图片URL',
    `sort_order` INT DEFAULT 0 COMMENT '排序顺序',
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='商品详细介绍图片表';

-- 4. 最热商品表
CREATE TABLE `hot_products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL UNIQUE COMMENT '关联的商品ID',
    `hot_score` INT DEFAULT 0 COMMENT '热度分值或排序序号',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='首页/最热商品推荐表';

## 后端接口文档

### 1. 全局说明

**Base URL**: http://localhost/v1

**数据格式**: Content-Type: application/json

**通用响应结构**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

**状态码说明**:
- 200: 请求成功
- 400: 参数错误
- 401: 未授权
- 500: 服务器内部错误

### 2. 用户认证模块

#### 2.1 用户注册
- **接口地址**: `/auth/register`
- **请求方式**: POST
- **请求参数**:
  ```json
  {
    "username": "testuser",
    "password": "password123",
    "email": "test@example.com",
    "phone": "13800138000",
    "role": "USER",
    "avatar_url": "http://example.com/avatar.jpg",
    "remarks": "个人备注"
  }
  ```
- **参数说明**:
  - `username`: 用户名（必填）
  - `password`: 密码（必填）
  - `email`: 邮箱（必填）
  - `phone`: 手机号（必填）
  - `role`: 身份类型（可选，默认为USER）
    - `USER`: 普通用户
    - `MERCHANT`: 商家
  - `avatar_url`: 头像地址（可选）
  - `remarks`: 备注（可选）
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

#### 2.2 用户登录
- **接口地址**: `/auth/login`
- **请求方式**: POST
- **请求参数**:
  ```json
  {
    "username": "testuser",
    "password": "password123"
  }
  ```
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "userInfo": {
        "id": 1,
        "username": "testuser",
        "email": "test@example.com",
        "phone": "13800138000",
        "avatar_url": "http://example.com/avatar.jpg",
        "remarks": "个人备注"
      }
    }
  }
  ```

#### 2.3 用户登出
- **接口地址**: `/auth/logout`
- **请求方式**: POST
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 3. 商品展示模块

**重要说明**: 所有商品查询接口都会自动过滤掉状态为 `OFF_SALE`（下架）的商品，仅展示 `ON_SALE`（在售）和 `OUT_OF_STOCK`（缺货）状态的商品。

#### 3.1 获取商品列表
- **接口地址**: `/products`
- **请求方式**: GET
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
  - `isHot`: 是否只查询最热商品 (可选)
  - `category`: 商品分类 (可选，如：保健品、医疗器械、健康食品、运动健身、母婴用品)
  - `minPrice`: 最低价格 (可选)
  - `maxPrice`: 最高价格 (可选)
  - `sortBy`: 排序字段 (可选，如：price、stock、sales)
  - `sortOrder`: 排序方向 (可选，asc升序、desc降序)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "category": "保健品",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

#### 3.2 搜索商品
- **接口地址**: `/products/search`
- **请求方式**: GET
- **查询参数**:
  - `keyword`: 搜索关键词 (匹配商品标题或描述)
  - `minPrice`: 最低价格
  - `maxPrice`: 最高价格
  - `sortBy`: 排序字段 (price_asc, price_desc, newest)
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

#### 3.3 获取最热商品
- **接口地址**: `/products/hot`
- **请求方式**: GET
- **查询参数**:
  - `limit`: 返回数量 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://example.com/products/vitamin_c.jpg",
        "price": 98.00,
        "stock": 100
      }
    ]
  }
  ```

#### 3.4 获取商品详情
- **接口地址**: `/products/{id}`
- **请求方式**: GET
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://example.com/products/vitamin_c.jpg",
      "features": {},
      "price": 98.00,
      "stock": 100,
      "detailImages": [
        "http://example.com/products/vitamin_c_detail1.jpg",
        "http://example.com/products/vitamin_c_detail2.jpg"
      ]
    }
  }
  ```

#### 3.5 按分类获取商品
- **接口地址**: `/products/category/{category}`
- **请求方式**: GET
- **路径参数**:
  - `category`: 商品分类
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100
        }
      ],
      "total": 1,
      "page": 1,
      "size": 10
    }
  }
  ```

### 4. 前端测试页面

访问地址: http://localhost/test.html

该页面提供了完整的API测试界面，包括：
- 用户注册/登录/登出
- 商品列表查询
- 商品搜索
- 最热商品展示
- 商品详情查看

### 5. 前端部署

#### 5.1 前端技术栈
- Vue 3 + Vite
- Vue Router (路由管理)
- Pinia (状态管理)
- Axios (HTTP客户端)
- 拟物化设计风格

#### 5.2 前端页面
- 首页 (http://localhost/): 展示热门商品和导航
- 商品列表页 (http://localhost/products): 支持分页、分类筛选、价格区间筛选、排序
- 搜索页 (http://localhost/search): 关键词搜索商品
- 登录页 (http://localhost/login): 用户登录，底部有注册入口
- 注册页 (http://localhost/register): 用户注册，支持填写邮箱、手机号，可选择用户/商家身份
- 个人中心 (http://localhost/profile): 用户信息（包括用户名、邮箱、手机号）和订单管理
- 商家管理后台 (http://localhost/merchant): 商家商品管理界面，仅商家用户可见

#### 5.3 功能说明
- 注册功能：用户可以在注册页面填写用户名、密码、邮箱、手机号等信息进行注册，支持选择普通用户或商家身份
- 登录功能：支持用户名密码登录，登录成功后显示用户头像和退出按钮
- 个人中心：显示完整的用户信息，包括用户名、邮箱、手机号等
- 商家后台：商家用户登录后可以在个人中心看到醒目的商家后台入口，或通过导航栏直接访问
- 商品筛选：支持按分类（保健品、医疗器械、健康食品、运动健身、母婴用品）筛选
- 价格筛选：支持按价格区间筛选商品
- 商品排序：支持按价格（升序/降序）、销量、库存等字段排序

#### 5.4 Docker部署
前端已配置Docker容器化部署，使用docker-compose.yml统一管理：

```bash
# 启动所有服务（包括前端）
docker-compose up -d

# 查看前端容器状态
docker ps | grep mall-frontend

# 查看前端日志
docker logs mall-frontend
```

前端容器配置：
- 容器名称: mall-frontend
- 内部端口: 80
- 外部访问: http://localhost (通过Nginx代理)
- 构建上下文: ./frontend
- 依赖服务: mall-backend

#### 5.5 本地开发
如需本地开发前端：

```bash
cd frontend
npm install
npm run dev
```

开发服务器地址: http://localhost:3000

### 6. 最近更新

#### 6.1 图片上传功能实现

**功能概述**:
实现了完整的图片上传和管理功能，支持用户头像、商品封面图和商品详情图的上传。

**主要特性**:
1. 前端自动图片处理
   - 用户头像：自动缩放至最大300x300像素，保持正方形
   - 商品封面图：自动缩放至最大800x600像素，保持原始比例
   - 商品详情图：强制16:9宽高比，最大1920x1080像素

2. 后端文件存储
   - 按图片类型和日期分类存储
   - 支持jpg、jpeg、png、gif格式
   - 文件大小限制5MB
   - 自动生成唯一文件名

3. 数据库集成
   - 用户表新增avatar_url字段存储头像URL
   - 商品表新增cover_url字段存储封面图URL
   - 商品详情图表存储多张详情图URL
   - 支持事务操作确保数据一致性

4. Nginx配置优化
   - 配置/v1/static路径代理静态资源
   - 支持缓存控制提高访问速度
   - 正确处理后端context-path

**相关文件**:
- [FileUploadService.java](file:///d:/bs25-2/backend/src/main/java/com/healthmall/service/FileUploadService.java) - 文件上传服务
- [imageProcessor.js](file:///d:/bs25-2/frontend/src/utils/imageProcessor.js) - 图片处理工具
- [ImageUpload.vue](file:///d:/bs25-2/frontend/src/components/ImageUpload.vue) - 图片上传组件
- [Profile.vue](file:///d:/bs25-2/frontend/src/views/Profile.vue) - 个人中心（头像上传）
- [ProductForm.vue](file:///d:/bs25-2/frontend/src/components/ProductForm.vue) - 商品表单（商品图片上传）

#### 6.2 商品图片上传功能重构（2026-01-30）

**功能概述**:
重构了商品创建和编辑流程，从输入图片URL改为直接上传文件，并增加了详细介绍图片上传功能。

**主要修改**:

1. **后端API重构**:
   - 商品创建接口 (`POST /merchant/products`) 改为 `multipart/form-data` 格式，支持文件上传
   - 商品更新接口 (`PUT /merchant/products/{id}`) 改为 `multipart/form-data` 格式
   - 新增详细介绍图片上传支持，可同时上传多张详情图
   - [MerchantProductRequest.java](file:///d:/26bs/backend/src/main/java/com/healthmall/dto/MerchantProductRequest.java) 新增 `detailImages` 字段

2. **前端表单重构**:
   - [ProductForm.vue](file:///d:/26bs/frontend/src/components/ProductForm.vue) 完全重构
   - 封面图片从URL输入改为文件上传组件
   - 新增详细介绍图片上传区域，支持多选上传
   - 图片预览功能，支持删除已选图片
   - 文件类型验证（jpg、png、gif）和大小限制（5MB）

3. **静态资源访问**:
   - [WebConfig.java](file:///d:/26bs/backend/src/main/java/com/healthmall/config/WebConfig.java) 添加静态资源映射
   - 配置 `/static/**` 路径映射到文件系统
   - 上传图片存储路径：`/app/static/product/cover/` 和 `/app/static/product/detail/`

4. **表单交互优化**:
   - 移除点击遮罩层关闭表单的功能，防止误操作
   - 添加右上角关闭按钮（×）
   - 修复文件上传后表单自动关闭的问题
   - 添加事件阻止冒泡处理

**API变更示例**:
```javascript
// 创建商品 - 使用 FormData
const formData = new FormData();
formData.append('title', '商品名称');
formData.append('category', '保健品');
formData.append('description', '商品描述');
formData.append('price', '99.99');
formData.append('stock', '100');
formData.append('coverImage', coverFile);  // 文件对象
formData.append('detailImages', detailFile1);  // 多张详情图
formData.append('detailImages', detailFile2);
formData.append('status', 'ON_SALE');

await api.post('/merchant/products', formData, {
  headers: { 'Content-Type': 'multipart/form-data' }
});
```

#### 6.3 数据库更新
- 用户表新增字段：`email`（邮箱地址）、`phone`（手机号码）、`role`（用户角色）
- 商品表新增字段：`merchant_id`（商家ID）、`category`（商品分类）、`sales`（销量）、`status`（商品状态）
- 执行SQL更新脚本：`UpdateSchema.sql`

#### 6.2 功能修复
1. 个人界面信息显示问题
   - 修复了个人界面只显示用户名，其他字段为空的问题
   - 现在个人中心完整显示用户名、邮箱、手机号等信息

2. 商品列表分类和排序功能
   - 修复了商品列表页的分类筛选和排序功能不生效的问题
   - 前端参数从 `pageSize` 改为 `size` 以匹配后端API
   - 现在支持按分类、价格区间、排序字段进行筛选和排序

3. 注册功能完善
   - 添加了完整的注册页面，支持填写邮箱和手机号
   - 登录页面底部添加了注册入口链接
   - Header组件在未登录状态下显示注册按钮

4. API返回数据修复
   - 重新构建后端容器，确保LoginResponse正确返回email和phone字段
   - 重新构建前端容器，确保前端使用最新代码
   - 验证API测试确认登录接口正确返回用户完整信息

5. 商家API拦截器配置修复
   - 修复了商家API路径未配置认证拦截器的问题
   - 在 [WebConfig.java](file:///d:/bs25-2/backend/src/main/java/com/healthmall/config/WebConfig.java) 中添加 `/merchant/**` 路径到拦截器配置
   - 现在商家API需要携带token才能访问，确保数据安全
   - 修复了添加商品时 merchantId 为 null 的问题

6. JSON反序列化问题修复
   - 修复了商家添加商品时的JSON反序列化错误
   - 问题原因：前端发送的features字段为JSON对象，但后端定义为String类型
   - 解决方案：
     - 创建了自定义反序列化器 [JsonToStringDeserializer.java](file:///d:/bs25-2/backend/src/main/java/com/healthmall/util/JsonToStringDeserializer.java)
     - 在 [MerchantProductRequest.java](file:///d:/bs25-2/backend/src/main/java/com/healthmall/dto/MerchantProductRequest.java) 中为features字段添加@JsonDeserialize注解
   - 现在支持前端发送JSON格式的features数据，后端自动转换为JSON字符串存储
   - 前端发送示例：
     ```json
     {
       "title": "商品名称",
       "category": "保健品",
       "description": "商品描述",
       "coverUrl": "http://example.com/image.jpg",
       "features": {
         "brand": "品牌名",
         "specification": "规格",
         "origin": "产地"
       },
       "price": 99.99,
       "stock": 100,
       "status": "ON_SALE"
     }
     ```

### 8. 图片上传模块

#### 8.1 上传商品图片
- **接口地址**: `/upload/image`
- **请求方式**: POST
- **请求头**: 需要携带token
- **请求类型**: multipart/form-data
- **请求参数**:
  - `file`: 图片文件（必填）
  - `type`: 图片类型（可选，用于区分不同用途的图片）
    - `avatar`: 用户头像
    - `product-cover`: 商品封面图
    - `product-detail`: 商品详情图
- **支持格式**: jpg, jpeg, png, gif
- **文件大小限制**: 最大5MB
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "上传成功",
    "data": {
      "url": "http://localhost/v1/static/product/cover/2025/12/30/abc123.jpg"
    }
  }
  ```

#### 8.2 图片处理规则

系统在前端对上传的图片进行自动处理，以优化存储和显示效果：

**用户头像**:
- 尺寸限制: 最大300x300像素
- 保持正方形比例
- 自动缩放至合适尺寸

**商品封面图**:
- 尺寸限制: 最大800x600像素
- 保持原始宽高比
- 自动缩放至合适尺寸

**商品详情图**:
- 尺寸限制: 最大1920x1080像素
- 强制16:9宽高比
- 自动裁剪或填充以符合比例

#### 8.3 前端图片上传功能

**用户头像上传**:
- 访问路径: 个人中心页面
- 操作方式: 点击"更换头像"按钮打开上传对话框
- 支持拖拽上传或点击选择文件
- 上传成功后自动更新用户头像

**商品图片上传**:
- 访问路径: 商家管理后台 -> 添加/编辑商品
- 支持上传商品封面图
- 支持上传最多5张商品详情图
- 可预览已上传的图片
- 支持删除已上传的详情图

#### 8.4 图片存储路径

系统将图片按类型和日期分类存储：

```
/static/
├── user/
│   └── avatar/
│       └── {year}/{month}/{day}/
├── product/
│   ├── cover/
│   │   └── {year}/{month}/{day}/
│   └── detail/
│       └── {year}/{month}/{day}/
```

#### 8.5 图片访问方式

通过Nginx代理访问静态资源：
- 访问路径: `http://localhost/v1/static/{type}/{category}/{year}/{month}/{day}/{filename}`
- 示例: `http://localhost/v1/static/product/cover/2025/12/30/abc123.jpg`

### 9. 商家商品管理模块

#### 9.1 商家添加商品
- **接口地址**: `/merchant/products`
- **请求方式**: POST
- **请求头**: 需要携带token
- **请求类型**: `multipart/form-data` (支持文件上传)
- **请求参数**:
  | 参数 | 类型 | 必填 | 说明 |
  |------|------|------|------|
  | title | string | 是 | 商品名称 |
  | category | string | 是 | 商品分类 |
  | description | string | 是 | 商品描述 |
  | coverImage | file | 是 | 封面图片文件 |
  | detailImages | file[] | 否 | 详细介绍图片文件数组（可选，可多选） |
  | price | decimal | 是 | 价格 |
  | stock | int | 是 | 库存 |
  | status | string | 否 | 状态: ON_SALE/OFF_SALE/OUT_OF_STOCK |
  | features | string | 否 | JSON格式字符串 |

- **请求示例** (使用FormData):
  ```javascript
  const formData = new FormData();
  formData.append('title', '天然维C片500mg');
  formData.append('category', '保健品');
  formData.append('description', '富含维生素C');
  formData.append('coverImage', fileInput.files[0]); // 封面图片文件
  formData.append('detailImages', detailFile1); // 详细介绍图片（可多选）
  formData.append('detailImages', detailFile2);
  formData.append('detailImages', detailFile3);
  formData.append('price', '98.00');
  formData.append('stock', '100');
  formData.append('status', 'ON_SALE');
  
  await api.post('/merchant/products', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  ```

- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://localhost/v1/static/product/cover/2025/01/15/abc123.jpg",
      "detailImages": [
        "http://localhost/v1/static/product/detail/2025/01/15/def456.jpg",
        "http://localhost/v1/static/product/detail/2025/01/15/ghi789.jpg"
      ],
      "features": {},
      "price": 98.00,
      "stock": 100,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

#### 9.2 商家修改商品
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: PUT
- **请求头**: 需要携带token
- **请求类型**: `multipart/form-data` (支持文件上传)
- **路径参数**:
  - `id`: 商品ID
- **请求参数**:
  | 参数 | 类型 | 必填 | 说明 |
  |------|------|------|------|
  | title | string | 是 | 商品名称 |
  | category | string | 是 | 商品分类 |
  | description | string | 是 | 商品描述 |
  | coverImage | file | 否 | 新封面图片文件（不传则保留原图） |
  | detailImages | file[] | 否 | 详细介绍图片文件数组（可选） |
  | price | decimal | 是 | 价格 |
  | stock | int | 是 | 库存 |
  | status | string | 否 | 状态: ON_SALE/OFF_SALE/OUT_OF_STOCK |
  | features | string | 否 | JSON格式字符串 |

- **请求示例** (使用FormData):
  ```javascript
  const formData = new FormData();
  formData.append('title', '天然维C片500mg（升级版）');
  formData.append('category', '保健品');
  formData.append('description', '富含维生素C，升级配方');
  formData.append('coverImage', newCoverFile); // 新封面图片（可选）
  formData.append('detailImages', detailFile1); // 详细介绍图片（可选）
  formData.append('detailImages', detailFile2);
  formData.append('price', '108.00');
  formData.append('stock', '150');
  formData.append('status', 'ON_SALE');
  
  await api.put(`/merchant/products/${productId}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  ```
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg（升级版）",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化，升级配方",
      "coverUrl": "http://localhost/v1/static/product/cover/2025/01/15/abc123.jpg",
      "detailImages": [
        "http://localhost/v1/static/product/detail/2025/01/15/def456.jpg",
        "http://localhost/v1/static/product/detail/2025/01/15/ghi789.jpg"
      ],
      "features": {},
      "price": 108.00,
      "stock": 150,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

#### 9.3 商家删除商品
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: DELETE
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

#### 9.4 商家查询商品列表
- **接口地址**: `/merchant/products`
- **请求方式**: GET
- **请求头**: 需要携带token
- **查询参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
  - `status`: 商品状态 (可选，ON_SALE/OFF_SALE/OUT_OF_STOCK)
  - `category`: 商品分类 (可选)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "list": [
        {
          "id": 1,
          "title": "天然维C片500mg",
          "category": "保健品",
          "coverUrl": "http://example.com/products/vitamin_c.jpg",
          "price": 98.00,
          "stock": 100,
          "sales": 0,
          "status": "ON_SALE",
          "merchantId": 1
        }
      ],
      "total": 1
    }
  }
  ```

#### 9.5 商家查询商品详情
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: GET
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "title": "天然维C片500mg",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力，抗氧化",
      "coverUrl": "http://example.com/products/vitamin_c.jpg",
      "features": {},
      "price": 98.00,
      "stock": 100,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

#### 9.6 商家更新商品状态
- **接口地址**: `/merchant/products/{id}/status`
- **请求方式**: PATCH
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **查询参数**:
  - `status`: 商品状态 (ON_SALE/OFF_SALE/OUT_OF_STOCK)
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

#### 9.7 商家更新商品库存
- **接口地址**: `/merchant/products/{id}/stock`
- **请求方式**: PATCH
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **查询参数**:
  - `stock`: 库存数量
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 9. 测试账号

系统提供以下测试账号用于功能测试：

#### 8.1 普通用户测试账号

- **用户名**: HETAO
- **密码**: 7410852963
- **邮箱**: 13@FON.com
- **手机号**: 13800138005

使用此账号登录后，可以在个人中心查看完整的用户信息，包括用户名、邮箱和手机号。

#### 8.2 商家测试账号

- **用户名**: MALL
- **密码**: 7410852963
- **邮箱**: MALL@SHOP.com
- **手机号**: 13800138202
- **角色**: MERCHANT

使用此账号登录后，可以访问商家商品管理接口，包括添加、修改、删除、查询商品，以及更新商品状态和库存。

**商家 API 测试示例（PowerShell）**:

```powershell
# 1. 商家登录获取token
$headers = @{"Content-Type"="application/json"}
$body = @{username="MALL";password="7410852963"} | ConvertTo-Json
$response = Invoke-WebRequest -Uri "http://localhost/v1/auth/login" -Method POST -Headers $headers -Body $body -UseBasicParsing
$token = ($response.Content | ConvertFrom-Json).data.token

# 2. 添加商品
$headers = @{"Content-Type"="application/json";"Authorization"="Bearer $token"}
$body = @{
    title="天然维C片500mg"
    category="保健品"
    description="富含维生素C，增强免疫力，抗氧化"
    coverUrl="http://example.com/products/vitamin_c.jpg"
    features=@{brand="健康品牌";specification="500mg/片";origin="中国"}
    price=98.00
    stock=100
    status="ON_SALE"
} | ConvertTo-Json -Depth 3
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products" -Method POST -Headers $headers -Body $body -UseBasicParsing
$response.Content

# 3. 查询商品列表
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products?page=1&size=10" -Method GET -Headers $headers -UseBasicParsing
$response.Content

# 4. 修改商品
$body = @{
    title="天然维C片1000mg"
    category="保健品"
    description="高浓度维生素C，增强免疫力"
    coverUrl="http://example.com/products/vitamin_c_1000.jpg"
    features="{}"
    price=128.00
    stock=50
    status="ON_SALE"
} | ConvertTo-Json -Depth 3
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products/32" -Method PUT -Headers $headers -Body $body -UseBasicParsing
$response.Content

# 5. 更新商品状态
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products/32/status?status=OFF_SALE" -Method PATCH -Headers $headers -UseBasicParsing
$response.Content

# 6. 更新商品库存
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products/32/stock?stock=10" -Method PATCH -Headers $headers -UseBasicParsing
$response.Content

# 7. 删除商品
$response = Invoke-WebRequest -Uri "http://localhost/v1/merchant/products/32" -Method DELETE -Headers $headers -UseBasicParsing
$response.Content
```

### 9. 商家前端管理界面

#### 9.1 访问方式
商家用户登录后可以通过以下方式访问商家管理后台：
1. **个人中心入口**：登录后进入个人中心页面，顶部会显示醒目的商家后台入口卡片
2. **导航栏入口**：登录后导航栏会显示"🏪 商家后台"链接（橙色背景）

访问地址: http://localhost/merchant

#### 9.2 功能特性
商家管理后台提供完整的商品管理功能，采用拟物化设计风格，界面友好易用：

- **商品列表展示**：
  - 支持按商品状态筛选（全部/在售/下架/缺货）
  - 支持按商品分类筛选（保健品/医疗器械/健康食品/运动健身/母婴用品）
  - 显示商品封面、名称、分类、价格、库存、销量、状态等信息
  - 支持分页浏览

- **商品添加**：
  - 点击"添加商品"按钮打开添加表单
  - 支持填写商品名称、分类、描述、封面URL、价格、库存、状态
  - 商品特征字段采用JSON格式，方便扩展
  - 表单验证确保必填字段完整

- **商品编辑**：
  - 点击商品列表中的"编辑"按钮打开编辑表单
  - 自动填充商品当前信息
  - 支持修改所有商品属性
  - 保存后立即更新商品列表

- **商品删除**：
  - 点击商品列表中的"删除"按钮
  - 弹出确认对话框防止误操作
  - 删除成功后自动刷新列表

- **快速操作**：
  - 直接在商品列表中更新商品状态（在售/下架/缺货）
  - 直接在商品列表中更新商品库存
  - 操作实时生效，无需跳转页面

#### 9.3 界面设计
商家管理后台采用拟物化设计风格，具有以下特点：
- 卡片式布局，层次分明
- 阴影和渐变效果，增强立体感
- 橙色主题色调，突出商家身份
- 响应式设计，支持移动端访问
- 清晰的操作按钮和状态标识

#### 9.4 权限控制
- 只有商家角色（MERCHANT）的用户可以访问商家管理后台
- 普通用户访问会自动重定向到首页
- 所有操作都需要携带有效的JWT token
- 商家只能管理自己的商品，无法查看或修改其他商家的商品

#### 9.5 使用流程
1. 使用商家账号（MALL / 7410852963）登录系统
2. 登录后进入个人中心，点击醒目的橙色商家后台入口
3. 或直接点击导航栏中的"🏪 商家后台"链接
4. 进入商家管理后台，开始管理您的商品
5. 点击"添加商品"按钮添加新商品
6. 在商品列表中可以查看、编辑、删除商品
7. 使用筛选功能快速查找特定商品
8. 使用快速操作功能更新商品状态和库存

### 10. 管理员商品管理模块

#### 10.1 管理员创建商品
- **接口地址**: `/admin/products`
- **请求方式**: POST
- **请求头**: 需要携带token (ADMIN角色)
- **请求类型**: `multipart/form-data` (支持文件上传)
- **请求参数**:
  | 参数 | 类型 | 必填 | 说明 |
  |------|------|------|------|
  | name | string | 是 | 商品名称 |
  | category | string | 是 | 商品分类 |
  | description | string | 是 | 商品描述 |
  | coverImage | file | 是 | 封面图片文件 |
  | price | decimal | 是 | 价格 |
  | stock | int | 是 | 库存 |
  | features | string | 否 | JSON格式字符串 |

- **请求示例** (使用FormData):
  ```javascript
  const formData = new FormData();
  formData.append('name', '天然维C片500mg');
  formData.append('category', '保健品');
  formData.append('description', '富含维生素C');
  formData.append('coverImage', fileInput.files[0]); // 文件对象
  formData.append('price', '98.00');
  formData.append('stock', '100');
  ```

- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": 1
  }
  ```

#### 10.2 管理员删除商品
- **接口地址**: `/admin/products/{id}`
- **请求方式**: DELETE
- **请求头**: 需要携带token (ADMIN角色)
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

#### 10.3 商品图片上传说明
创建商品时，封面图片通过 `coverImage` 字段上传，支持以下格式：
- **支持格式**: jpg, jpeg, png, gif
- **文件大小限制**: 最大 5MB
- **存储路径**: `/static/product/cover/{year}/{month}/{day}/{filename}`
- **访问URL**: `http://localhost/v1/static/product/cover/{year}/{month}/{day}/{filename}`

**PowerShell 测试示例**:
```powershell
# 管理员登录
$headers = @{"Content-Type"="application/json"}
$body = @{username="admin";password="admin123"} | ConvertTo-Json
$response = Invoke-WebRequest -Uri "http://localhost/v1/auth/login" -Method POST -Headers $headers -Body $body -UseBasicParsing
$token = ($response.Content | ConvertFrom-Json).data.token

# 创建商品（带图片上传）
$headers = @{"Authorization"="Bearer $token"}
$form = @{
    name="测试商品"
    category="保健品"
    description="测试描述"
    price="99.99"
    stock="100"
}
# 使用 -InFile 参数上传图片文件
Invoke-WebRequest -Uri "http://localhost/v1/admin/products" -Method POST -Headers $headers -Form $form -InFile "path/to/image.jpg" -UseBasicParsing
```
