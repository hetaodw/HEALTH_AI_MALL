# 健康商城系统 - 启动指南

## 项目结构

```
bs25-2/
├── docker-compose.yml          # Docker编排文件
├── Start.sql                    # 数据库初始化脚本
├── backend/                     # Spring Boot后端
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/healthmall/
│       │   ├── common/          # 通用类
│       │   ├── config/          # 配置类
│       │   ├── controller/      # 控制器
│       │   ├── dto/             # 数据传输对象
│       │   ├── entity/          # 数据库实体
│       │   ├── exception/       # 异常处理
│       │   ├── interceptor/     # 拦截器
│       │   ├── repository/      # 数据访问层
│       │   ├── service/         # 业务逻辑层
│       │   └── util/            # 工具类
│       └── resources/
│           └── application.yml  # 应用配置
└── nginx/                       # Nginx配置
    ├── nginx.conf
    └── conf.d/
        └── default.conf
```

## 技术栈

- **后端框架**: Spring Boot 3.2.0
- **数据库**: MySQL 8.0
- **缓存**: Redis 7
- **Web服务器**: Nginx
- **容器化**: Docker & Docker Compose
- **ORM**: Spring Data JPA
- **认证**: JWT (JSON Web Token)

## 启动步骤

### 1. 使用Docker Compose启动所有服务

```bash
docker-compose up -d
```

这将启动以下服务：
- `mall-mysql`: MySQL数据库服务 (端口3306)
- `mall-redis`: Redis缓存服务 (端口6379)
- `mall-backend`: Spring Boot后端服务 (端口8080)
- `mall-nginx`: Nginx反向代理 (端口80)

### 2. 查看服务状态

```bash
docker-compose ps
```

### 3. 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f mall-backend
```

### 4. 停止服务

```bash
docker-compose down
```

## API接口文档

### 基础URL

```
http://localhost/v1
```

### 通用响应格式

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

### 用户认证模块

#### 1. 用户注册
- **接口**: `POST /auth/register`
- **请求体**:
```json
{
  "username": "testuser",
  "password": "password123",
  "avatar_url": "http://example.com/avatar.jpg",
  "remarks": "个人简介"
}
```

#### 2. 用户登录
- **接口**: `POST /auth/login`
- **请求体**:
```json
{
  "username": "testuser",
  "password": "password123"
}
```
- **响应**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userInfo": {
      "id": 1,
      "username": "testuser",
      "avatarUrl": "http://example.com/avatar.jpg"
    }
  }
}
```

#### 3. 用户登出
- **接口**: `POST /auth/logout`

### 商品展示模块

#### 1. 获取商品列表
- **接口**: `GET /products?page=1&size=10&is_hot=false`
- **参数**:
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)
  - `is_hot`: 是否只查询最热商品 (可选)

#### 2. 搜索商品
- **接口**: `GET /products/search?keyword=鱼油&min_price=100&max_price=500&page=1&size=10`
- **参数**:
  - `keyword`: 搜索关键词 (可选)
  - `min_price`: 最低价 (可选)
  - `max_price`: 最高价 (可选)
  - `sortBy`: 排序字段 (可选)
  - `page`: 页码 (默认1)
  - `size`: 每页条数 (默认10)

#### 3. 获取最热商品
- **接口**: `GET /products/hot?limit=10`

#### 4. 获取商品详情
- **接口**: `GET /products/{id}`

### 用户个人信息模块 (需要登录)

所有需要认证的接口都需要在请求头中携带Token：
```
Authorization: Bearer {token}
```

#### 1. 获取当前用户信息
- **接口**: `GET /user/profile`

#### 2. 修改用户资料
- **接口**: `PUT /user/profile/update`
- **参数**:
  - `avatar_url`: 新头像链接 (可选)
  - `remarks`: 新的个人备注 (可选)

### 管理员模块 (需要登录)

#### 1. 发布新商品
- **接口**: `POST /admin/products`

#### 2. 删除商品
- **接口**: `DELETE /admin/products/{id}`

## 数据库表结构

### users (用户表)
- `id`: 用户ID
- `username`: 用户名
- `password`: 密码 (加密)
- `avatar_url`: 头像URL
- `remarks`: 备注
- `created_at`: 创建时间

### products (商品表)
- `id`: 商品ID
- `title`: 商品名称
- `description`: 商品描述
- `cover_url`: 封面图URL
- `features`: 商品特征 (JSON)
- `price`: 价格
- `stock`: 库存
- `created_at`: 创建时间

### product_details_images (商品详情图片表)
- `id`: 图片ID
- `product_id`: 商品ID
- `image_url`: 图片URL
- `sort_order`: 排序

### hot_products (最热商品表)
- `id`: ID
- `product_id`: 商品ID
- `hot_score`: 热度分数
- `updated_at`: 更新时间

## 常见问题

### 1. 数据库连接失败
检查MySQL容器是否正常运行：
```bash
docker-compose ps mall-mysql
```

### 2. 后端服务启动失败
查看后端日志：
```bash
docker-compose logs mall-backend
```

### 3. 端口冲突
如果端口被占用，可以修改 `docker-compose.yml` 中的端口映射。

## 开发说明

### 本地开发

如果需要在本地开发而不使用Docker，需要：
1. 安装MySQL 8.0
2. 安装Redis 7
3. 修改 `backend/src/main/resources/application.yml` 中的数据库和Redis连接配置
4. 运行 `Start.sql` 初始化数据库
5. 使用Maven启动项目：
```bash
cd backend
mvn spring-boot:run
```

### 添加新的API

1. 在 `controller` 包中创建新的Controller
2. 在 `service` 包中创建对应的Service
3. 在 `repository` 包中创建对应的Repository (如需要)
4. 在 `dto` 包中创建请求和响应对象

## 注意事项

1. 默认JWT密钥为 `health-mall-secret-key-2024`，生产环境请修改
2. 数据库默认密码为 `root123456`，生产环境请修改
3. Redis默认无密码，生产环境请配置密码
4. 所有密码都使用BCrypt加密存储
