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
    `remarks` TEXT DEFAULT NULL COMMENT '备注信息',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE=InnoDB COMMENT='用户信息表';

-- 2. 商品表
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '商品唯一标识',
    `title` VARCHAR(100) NOT NULL COMMENT '商品名称',
    `description` TEXT COMMENT '商品详细描述',
    `cover_url` VARCHAR(255) NOT NULL COMMENT '商品封面图片URL',
    `features` JSON DEFAULT NULL COMMENT '商品特征（暂时留空，使用JSON格式方便扩展）',
    `price` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格',
    `stock` INT DEFAULT 0 COMMENT '库存',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    "avatar_url": "http://example.com/avatar.jpg",
    "remarks": "个人备注"
  }
  ```
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
- 注册页 (http://localhost/register): 用户注册，支持填写邮箱和手机号
- 个人中心 (http://localhost/profile): 用户信息（包括用户名、邮箱、手机号）和订单管理

#### 5.3 功能说明
- 注册功能：用户可以在注册页面填写用户名、密码、邮箱、手机号等信息进行注册
- 登录功能：支持用户名密码登录，登录成功后显示用户头像和退出按钮
- 个人中心：显示完整的用户信息，包括用户名、邮箱、手机号等
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
- 用户表新增字段：`email`（邮箱地址）、`phone`（手机号码）
- 执行SQL更新脚本：`update_user_table.sql`

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