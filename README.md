1.系统使用docker构建
2.系统使用mysql数据库，数据库地址为mysql://mall-mysql:3306/health_mall_system，外部访问端口为4000
utf8mb4编码
3.系统使用redis数据库，数据库地址为redis://mall-redis:6379/0
4.系统使用nginx作为web服务器，nginx配置文件为/etc/nginx/nginx.conf
5：系统将使用docker-compose.yml文件启动，启动时需要初始化数据库等

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
    `status` ENUM('ON_SALE', 'OFF_SALE', 'OUT_OF_STOCK') DEFAULT 'ON_SALE' COMMENT '商品状态：ON_SALE-在售，OFF_SALE-下架，OUT_OF_STOCK-缺货',
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

#### 6.1 数据库更新
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

### 7. 商家商品管理模块

#### 7.1 商家添加商品
- **接口地址**: `/merchant/products`
- **请求方式**: POST
- **请求头**: 需要携带token
- **请求参数**:
  ```json
  {
    "title": "天然维C片500mg",
    "category": "保健品",
    "description": "富含维生素C，增强免疫力，抗氧化",
    "coverUrl": "http://example.com/products/vitamin_c.jpg",
    "features": {},
    "price": 98.00,
    "stock": 100,
    "status": "ON_SALE"
  }
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

#### 7.2 商家修改商品
- **接口地址**: `/merchant/products/{id}`
- **请求方式**: PUT
- **请求头**: 需要携带token
- **路径参数**:
  - `id`: 商品ID
- **请求参数**:
  ```json
  {
    "title": "天然维C片500mg（升级版）",
    "category": "保健品",
    "description": "富含维生素C，增强免疫力，抗氧化，升级配方",
    "coverUrl": "http://example.com/products/vitamin_c_new.jpg",
    "features": {},
    "price": 108.00,
    "stock": 150,
    "status": "ON_SALE"
  }
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
      "coverUrl": "http://example.com/products/vitamin_c_new.jpg",
      "features": {},
      "price": 108.00,
      "stock": 150,
      "sales": 0,
      "status": "ON_SALE",
      "merchantId": 1
    }
  }
  ```

#### 7.3 商家删除商品
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

#### 7.4 商家查询商品列表
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

#### 7.5 商家查询商品详情
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

#### 7.6 商家更新商品状态
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

#### 7.7 商家更新商品库存
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

### 8. 测试账号

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
    features="{}"
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