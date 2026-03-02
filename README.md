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

-- 5. 收货地址表
CREATE TABLE `addresses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL COMMENT '用户ID',
    `receiver_name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `province` VARCHAR(50) COMMENT '省份',
    `city` VARCHAR(50) COMMENT '城市',
    `district` VARCHAR(50) COMMENT '区县',
    `detail_address` VARCHAR(255) NOT NULL COMMENT '详细地址',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认地址',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='收货地址表';

-- 6. 订单表
CREATE TABLE `orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(32) NOT NULL UNIQUE COMMENT '订单号（雪花算法生成）',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `status` ENUM('PENDING_PAYMENT', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING_PAYMENT' COMMENT '订单状态',
    `total_amount` DECIMAL(10, 2) NOT NULL COMMENT '订单总金额',
    `receiver_name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `receiver_address` VARCHAR(255) NOT NULL COMMENT '收货地址',
    `pay_expire_at` TIMESTAMP NULL COMMENT '支付过期时间',
    `paid_at` TIMESTAMP NULL COMMENT '支付时间',
    `shipped_at` TIMESTAMP NULL COMMENT '发货时间',
    `delivered_at` TIMESTAMP NULL COMMENT '收货时间',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='订单表';

-- 7. 订单项表
CREATE TABLE `order_items` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL COMMENT '订单ID',
    `product_id` INT NOT NULL COMMENT '商品ID',
    `snapshot_id` BIGINT NOT NULL COMMENT '商品快照ID',
    `quantity` INT NOT NULL COMMENT '购买数量',
    `unit_price` DECIMAL(10, 2) NOT NULL COMMENT '下单时单价',
    `total_price` DECIMAL(10, 2) NOT NULL COMMENT '小计金额',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='订单项表';

-- 8. 商品快照表
CREATE TABLE `product_snapshots` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL COMMENT '商品ID',
    `title` VARCHAR(100) NOT NULL COMMENT '商品标题',
    `category` VARCHAR(50) COMMENT '商品分类',
    `cover_url` VARCHAR(255) COMMENT '封面图URL',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '商品价格',
    `merchant_id` INT COMMENT '商家ID',
    `merchant_name` VARCHAR(50) COMMENT '商家名称',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='商品快照表';

-- 9. 支付记录表
CREATE TABLE `payments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(32) NOT NULL UNIQUE COMMENT '订单号',
    `pay_no` VARCHAR(64) COMMENT '支付流水号',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    `pay_method` ENUM('ALIPAY', 'WECHAT', 'BALANCE') COMMENT '支付方式',
    `status` ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING' COMMENT '支付状态',
    `paid_at` TIMESTAMP NULL COMMENT '支付时间',
    `notify_data` TEXT COMMENT '支付回调数据',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='支付记录表';

-- 10. 库存预占表
CREATE TABLE `stock_reservations` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
    `product_id` INT NOT NULL COMMENT '商品ID',
    `quantity` INT NOT NULL COMMENT '预占数量',
    `status` ENUM('RESERVED', 'CONFIRMED', 'RELEASED') NOT NULL DEFAULT 'RESERVED' COMMENT '预占状态',
    `expire_at` TIMESTAMP NOT NULL COMMENT '过期时间',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='库存预占表';

-- 11. 商品详情介绍表
CREATE TABLE `product_descriptions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL UNIQUE COMMENT '商品ID',
    `content` TEXT NOT NULL COMMENT '详情介绍内容',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='商品详情介绍表';

-- 12. 商品评价表
CREATE TABLE `product_reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL COMMENT '商品ID',
    `user_id` INT NOT NULL COMMENT '用户ID',
    `rating` TINYINT NOT NULL COMMENT '评分（1-5星）',
    `title` VARCHAR(100) COMMENT '评价标题',
    `content` TEXT COMMENT '评价内容',
    `is_anonymous` TINYINT(1) DEFAULT 0 COMMENT '是否匿名',
    `status` ENUM('APPROVED', 'PENDING', 'REJECTED') DEFAULT 'APPROVED' COMMENT '评价状态',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='商品评价表';

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
- 商品详情页 (http://localhost/products/:id): 商品信息、详情介绍、评价展示、加入购物车
- 搜索页 (http://localhost/search): 关键词搜索商品
- 购物车页 (http://localhost/cart): 商品选择、数量修改、结算
- 订单确认页 (http://localhost/order/confirm): 地址选择、支付方式、订单创建
- 登录页 (http://localhost/login): 用户登录，底部有注册入口
- 注册页 (http://localhost/register): 用户注册，支持填写邮箱、手机号，可选择用户/商家身份
- 个人中心 (http://localhost/profile): 用户信息（包括用户名、邮箱、手机号）、收货地址管理和订单管理
- 商家管理后台 (http://localhost/merchant): 商家商品管理界面，仅商家用户可见

#### 5.2.1 个人中心功能
- **个人信息展示**: 显示用户名、邮箱、手机号、注册时间等基本信息
- **头像上传**: 支持上传和更换用户头像
- **收货地址管理**:
  - 查看所有收货地址列表
  - 新建收货地址（支持设置默认地址）
  - 编辑已有地址
  - 删除地址
  - 设置默认地址
- **订单管理**:
  - 查看所有订单列表
  - 按状态筛选订单（全部/待付款/待发货/待收货/已完成）
  - 查看订单详情
  - 取消待付款订单
  - 支付订单（支持支付宝、微信、银行卡）
- **账户设置**: 修改密码、退出登录

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

#### 6.1 购物车和订单系统（2026-02-28）

**功能概述**:
实现了完整的购物车到下单流程，包括购物车管理、订单创建、支付模拟、库存预占等核心电商功能。

**主要特性**:
1. **购物车功能**
   - 商品添加/删除/数量修改
   - 商品选择/全选功能
   - 已选商品总价计算
   - 结算跳转订单确认页

2. **订单创建流程**
   - 收货地址选择
   - 订单商品展示（交易快照）
   - 支付方式选择（支付宝/微信/银行卡）
   - 订单金额汇总

3. **库存预占机制**
   - 下单时预占库存，防止超卖
   - 订单超时自动释放库存
   - 支付成功确认库存扣减

4. **商品快照**
   - 下单时保存商品信息快照
   - 记录商品标题、价格、封面等
   - 保证交易记录的完整性

5. **订单定时任务**
   - 每分钟检查超时订单
   - 自动取消超时未支付订单
   - 自动释放预占库存

6. **雪花算法订单号**
   - 生成全局唯一的64位订单号
   - 支持分布式环境

**数据库变更**:
- 新增 `orders` 表：订单主表
- 新增 `order_items` 表：订单项表
- 新增 `payments` 表：支付记录表
- 新增 `product_snapshots` 表：商品快照表
- 新增 `stock_reservations` 表：库存预占表
- 新增 `addresses` 表：收货地址表

**相关文件**:
- [Cart.vue](file:///d:/26bs/frontend/src/views/Cart.vue) - 购物车页面
- [OrderConfirm.vue](file:///d:/26bs/frontend/src/views/OrderConfirm.vue) - 订单确认页面
- [OrderController.java](file:///d:/26bs/backend/src/main/java/com/healthmall/controller/OrderController.java) - 订单控制器
- [OrderService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/OrderService.java) - 订单服务
- [StockReservationService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/StockReservationService.java) - 库存预占服务
- [OrderScheduledTask.java](file:///d:/26bs/backend/src/main/java/com/healthmall/task/OrderScheduledTask.java) - 订单定时任务
- [SnowflakeIdGenerator.java](file:///d:/26bs/backend/src/main/java/com/healthmall/util/SnowflakeIdGenerator.java) - 雪花算法ID生成器
- [PAYMENT_ARCHITECTURE.md](file:///d:/26bs/docs/PAYMENT_ARCHITECTURE.md) - 支付功能技术文档

#### 6.2 商品详情介绍和评价功能（2026-02-28）

**功能概述**:
新增了商品的文字详情介绍和用户评价功能，完善商品展示和互动能力。

**主要特性**:
1. **商品详情介绍功能**
   - 支持为每个商品添加详细的文字介绍
   - 每个商品只能有一条详情介绍记录
   - 支持创建、更新、删除操作
   - 详情介绍内容存储为 TEXT 类型，支持长文本
   - 商品详情 API 自动包含详情介绍内容

2. **商品评价功能**
   - 用户可以对商品进行评价（1-5 星评分）
   - 支持评价标题和详细内容
   - 支持匿名评价功能
   - 评价状态管理：已通过、待审核、已拒绝
   - 自动计算商品的平均评分和评价数量
   - 评价列表支持分页查询
   - 评价列表自动过滤未通过审核的评价

3. **评分统计功能**
   - 商品表新增 `average_rating` 字段存储平均评分
   - 商品表新增 `review_count` 字段存储评价数量
   - 创建/删除评价时自动更新商品评分统计
   - 商品列表和详情 API 均返回评分信息

4. **API 接口**
   - 商品详情介绍 API：
     - `GET /v1/product/descriptions/{productId}` - 获取商品详情介绍
     - `POST /v1/product/descriptions/{productId}` - 创建或更新详情介绍
     - `DELETE /v1/product/descriptions/{productId}` - 删除详情介绍
   - 商品评价 API：
     - `GET /v1/product/reviews/{productId}` - 获取商品评价列表
     - `GET /v1/product/reviews/detail/{reviewId}` - 获取评价详情
     - `POST /v1/product/reviews/{productId}` - 创建商品评价
     - `DELETE /v1/product/reviews/{reviewId}` - 删除商品评价
   - 商品详情 API 增强：
     - `GET /v1/products/{id}` - 新增返回 `descriptionContent`、`averageRating`、`reviewCount` 字段

**数据库变更**:
- 新增 `product_descriptions` 表：存储商品详情文字介绍
- 新增 `product_reviews` 表：存储用户评价信息
- 更新 `products` 表：新增 `average_rating` 和 `review_count` 字段

**相关文件**:
- [ProductDescription.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/ProductDescription.java) - 商品详情介绍实体
- [ProductReview.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/ProductReview.java) - 商品评价实体
- [ProductDescriptionController.java](file:///d:/26bs/backend/src/main/java/com/healthmall/controller/ProductDescriptionController.java) - 商品详情介绍控制器
- [ProductReviewController.java](file:///d:/26bs/backend/src/main/java/com/healthmall/controller/ProductReviewController.java) - 商品评价控制器
- [ProductDescriptionService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/ProductDescriptionService.java) - 商品详情介绍服务
- [ProductReviewService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/ProductReviewService.java) - 商品评价服务
- [ProductDescriptionRepository.java](file:///d:/26bs/backend/src/main/java/com/healthmall/repository/ProductDescriptionRepository.java) - 详情介绍数据访问层
- [ProductReviewRepository.java](file:///d:/26bs/backend/src/main/java/com/healthmall/repository/ProductReviewRepository.java) - 评价数据访问层

**数据库迁移**:
- 执行 [database/schema_updates.sql](file:///d:/26bs/database/schema_updates.sql) 进行数据库结构更新

#### 6.3 个人中心功能增强（2026-02-13）

**功能概述**:
完善了个人中心的订单管理和收货地址管理功能。

**主要特性**:
1. **订单管理功能**
   - 实时查询用户订单列表（调用 `/orders/my` 接口）
   - 支持按订单状态筛选（全部/待付款/待发货/待收货/已完成）
   - 订单详情查看弹窗
   - 待付款订单支持取消操作
   - 待付款订单支持支付（支付宝/微信/银行卡）
   - 订单状态实时显示（带颜色标识）

2. **收货地址管理功能**
   - 查看所有收货地址列表
   - 新建地址弹窗表单（收货人、电话、省市区、详细地址）
   - 编辑已有地址
   - 删除地址（带确认提示）
   - 设置默认地址
   - 默认地址特殊标识显示

3. **UI/UX优化**
   - 采用拟物化设计风格，与整体系统风格一致
   - 响应式布局，支持移动端访问
   - 弹窗交互优化，防止误操作
   - 加载状态和错误提示

**相关API**:
- [订单API](API_DOCUMENTATION.md#订单-api) - 订单查询、详情、取消、支付
- [地址管理API](API_DOCUMENTATION.md#地址管理-api) - 地址增删改查、设置默认

**相关文件**:
- [Profile.vue](file:///d:/26bs/frontend/src/views/Profile.vue) - 个人中心页面
- [api/index.js](file:///d:/26bs/frontend/src/api/index.js) - API接口封装

#### 6.4 图片上传功能实现

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

### 10. 商品详情与订单模块

#### 10.1 获取商品详情（用于商品详情页）
- **接口地址**: `/products/{id}`
- **请求方式**: GET
- **说明**: 不需要登录，公开访问
- **路径参数**:
  - `id`: 商品ID
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "merchantId": 3,
      "merchantName": "健康商城",
      "title": "天然维C片500mg",
      "category": "保健品",
      "description": "富含维生素C，增强免疫力",
      "coverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
      "features": "品牌：健康品牌，规格：500mg/片",
      "price": 999.00,
      "stock": 99,
      "sales": 0,
      "status": "ON_SALE",
      "createdAt": "2026-01-30T01:03:40",
      "detailImages": [
        "http://localhost:8080/v1/static/product/detail/2026/01/30/detail1.jpg",
        "http://localhost:8080/v1/static/product/detail/2026/01/30/detail2.jpg"
      ]
    }
  }
  ```

#### 10.2 创建订单
- **接口地址**: `/orders`
- **请求方式**: POST
- **请求头**: 需要携带token (Authorization: Bearer {token})
- **请求参数**:
  | 参数 | 类型 | 必填 | 说明 |
  |------|------|------|------|
  | productId | int | 是 | 商品ID |
  | quantity | int | 是 | 购买数量 |
  | receiverName | string | 是 | 收货人姓名 |
  | receiverPhone | string | 是 | 收货人电话 |
  | receiverAddress | string | 是 | 收货地址 |
  | remark | string | 否 | 订单备注 |

- **请求示例**:
  ```json
  {
    "productId": 1,
    "quantity": 2,
    "receiverName": "张三",
    "receiverPhone": "13800138000",
    "receiverAddress": "北京市朝阳区xxx街道xxx号",
    "remark": "请尽快发货"
  }
  ```

- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": {
      "id": 1,
      "orderNo": "202601300227557694",
      "userId": 4,
      "productId": 1,
      "productTitle": "天然维C片500mg",
      "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
      "quantity": 2,
      "unitPrice": 999.00,
      "totalAmount": 1998.00,
      "status": "PENDING_PAYMENT",
      "receiverName": "张三",
      "receiverPhone": "13800138000",
      "receiverAddress": "北京市朝阳区xxx街道xxx号",
      "remark": "请尽快发货",
      "paidAt": null,
      "shippedAt": null,
      "completedAt": null,
      "createdAt": "2026-01-30T02:27:55"
    }
  }
  ```

#### 10.3 查询我的订单列表
- **接口地址**: `/orders/my`
- **请求方式**: GET
- **请求头**: 需要携带token (Authorization: Bearer {token})
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": [
      {
        "id": 1,
        "orderNo": "202601300227557694",
        "productTitle": "天然维C片500mg",
        "productCoverUrl": "http://localhost:8080/v1/static/product/cover/2026/01/30/xxx.png",
        "quantity": 2,
        "totalAmount": 1998.00,
        "status": "PENDING_PAYMENT",
        "createdAt": "2026-01-30T02:27:55"
      }
    ]
  }
  ```

#### 10.4 查询订单详情
- **接口地址**: `/orders/{id}`
- **请求方式**: GET
- **请求头**: 需要携带token (Authorization: Bearer {token})
- **路径参数**:
  - `id`: 订单ID
- **返回示例**: 同创建订单返回格式

#### 10.5 取消订单
- **接口地址**: `/orders/{id}/cancel`
- **请求方式**: POST
- **请求头**: 需要携带token (Authorization: Bearer {token})
- **路径参数**:
  - `id`: 订单ID
- **说明**: 只能取消状态为"待付款"的订单
- **返回示例**:
  ```json
  {
    "code": 200,
    "msg": "操作成功",
    "data": null
  }
  ```

### 11. 管理员商品管理模块

#### 11.1 管理员创建商品
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

#### 11.2 管理员删除商品
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

#### 11.3 商品图片上传说明
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
