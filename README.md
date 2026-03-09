# 🛒 健康商城系统

<div align="center">

一个功能完善的健康产品电商平台,支持用户购物、商家管理、订单处理等完整电商流程。

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)
[![Vue 3](https://img.shields.io/badge/Vue-3-42b883)](https://vuejs.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6db33f)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1)](https://www.mysql.com/)
[![Redis](https://img.shields.io/badge/Redis-6.x-DC382D)](https://redis.io/)

</div>

## ✨ 功能特性

### 👤 用户端功能
- **用户认证**: 注册、登录、登出,支持普通用户和商家两种角色
- **商品浏览**: 商品列表、搜索、分类筛选、价格区间筛选、多维度排序
- **商品详情**: 完整的商品信息展示,包括详情图片、评价等
- **购物车管理**: 商品添加、删除、数量修改、选择结算
- **订单系统**: 订单创建、支付模拟、订单状态追踪、订单取消
- **个人中心**: 个人信息管理、收货地址管理、订单管理
- **评价系统**: 商品评价、评分、匿名评价

### 🏪 商家端功能
- **商品管理**: 商品上架、下架、编辑、删除
- **库存管理**: 库存数量管理、库存预警
- **订单处理**: 查看订单、订单状态更新
- **数据统计**: 销量统计、热门商品分析

### 🔧 系统特性
- **库存预占机制**: 防止超卖,保证库存准确性
- **商品快照**: 订单创建时保存商品信息,确保历史订单数据完整
- **分布式ID**: 使用雪花算法生成订单号,保证全局唯一
- **缓存优化**: Redis缓存热点数据,提升系统性能
- **容器化部署**: Docker + Docker Compose 一键部署

## 🏗️ 技术架构

### 后端技术栈
- **框架**: Spring Boot 3.x
- **数据库**: MySQL 8.0
- **缓存**: Redis 6.x
- **ORM**: MyBatis / JPA
- **构建工具**: Maven
- **容器化**: Docker

### 前端技术栈
- **框架**: Vue 3
- **构建工具**: Vite
- **路由**: Vue Router
- **状态管理**: Pinia
- **HTTP客户端**: Axios
- **UI设计**: 拟物化设计风格

### 基础设施
- **Web服务器**: Nginx
- **反向代理**: Nginx
- **容器编排**: Docker Compose

## 📊 数据库设计

系统包含12个核心数据表:

| 表名 | 说明 |
|------|------|
| users | 用户信息表 |
| products | 商品基础信息表 |
| product_details_images | 商品详情图片表 |
| hot_products | 最热商品推荐表 |
| addresses | 收货地址表 |
| orders | 订单表 |
| order_items | 订单项表 |
| product_snapshots | 商品快照表 |
| payments | 支付记录表 |
| stock_reservations | 库存预占表 |
| product_descriptions | 商品详情介绍表 |
| product_reviews | 商品评价表 |

## 🚀 快速开始

### 环境要求
- Docker Desktop
- Docker Compose
- PowerShell (Windows) 或 Bash (Linux/Mac)

### 一键启动

```bash
# 克隆项目
git clone https://github.com/yourusername/health-mall.git
cd health-mall

# 启动所有服务
docker-compose up -d

# 访问应用
# 前端: http://localhost
# 后端API: http://localhost/v1
# MySQL: localhost:4000
# Redis: localhost:6379
```

```bash
# 停止并删除容器
docker-compose stop mall-backend
docker-compose rm -f mall-backend

# 重新构建
docker-compose build --no-cache mall-backend

# 启动容器
docker-compose up -d mall-backend
```

## 📱 页面展示

### 用户端页面
- **首页**: 热门商品展示、分类导航
- **商品列表页**: 分页、筛选、排序
- **商品详情页**: 商品信息、详情介绍、评价
- **搜索页**: 关键词搜索
- **购物车页**: 商品管理、结算
- **订单确认页**: 地址选择、支付方式
- **登录/注册页**: 用户认证
- **个人中心**: 信息管理、地址管理、订单管理

### 商家端页面
- **商家管理后台**: 商品管理、订单管理、数据统计

## 🔑 测试账号

### 用户账号

| 用户名 | 密码 | 角色 | 邮箱 | 手机号 |
|-------|------|------|------|--------|
| testuser1 | Test123456 | USER | testuser1@example.com | 13800138001 |
| testuser2 | Test123456 | USER | testuser2@example.com | 13800138002 |
| testuser3 | Test123456 | USER | testuser3@example.com | 13800138003 |

### 商家账号

| 用户名 | 密码 | 角色 | 邮箱 | 手机号 |
|-------|------|------|------|--------|
| testmerchant1 | Test123456 | MERCHANT | testmerchant1@example.com | 13800138004 |
| testmerchant2 | Test123456 | MERCHANT | testmerchant2@example.com | 13800138005 |

## 📡 API文档

### 基础信息
- **Base URL**: `http://localhost/v1`
- **数据格式**: `application/json`

### 通用响应结构
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

### 主要接口

#### 用户认证
- `POST /auth/register` - 用户注册
- `POST /auth/login` - 用户登录
- `POST /auth/logout` - 用户登出

#### 商品管理
- `GET /products` - 获取商品列表
- `GET /products/search` - 搜索商品
- `GET /products/hot` - 获取最热商品
- `GET /products/{id}` - 获取商品详情
- `GET /products/category/{category}` - 按分类获取商品

#### 购物车
- `GET /cart` - 获取购物车
- `POST /cart` - 添加商品到购物车
- `PUT /cart/{id}` - 更新购物车商品数量
- `DELETE /cart/{id}` - 删除购物车商品

#### 订单管理
- `POST /orders` - 创建订单
- `GET /orders` - 获取订单列表
- `GET /orders/{id}` - 获取订单详情
- `POST /orders/{id}/cancel` - 取消订单

详细API文档请参考 [API文档](./docs/API.md)

## 🎯 项目结构

```
health-mall/
├── backend/              # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   └── resources/
│   │   └── test/
│   ├── pom.xml
│   └── Dockerfile
├── frontend/             # 前端项目
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── router/
│   │   └── store/
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml    # Docker编排文件
├── nginx/                # Nginx配置
└── README.md
```

## 🔧 服务端口

| 服务 | 容器端口 | 映射端口 | 说明 |
|------|----------|----------|------|
| mall-backend | 8080 | 8080 | 后端API服务 |
| mall-mysql | 3306 | 4000 | MySQL数据库 |
| mall-redis | 6379 | 6379 | Redis缓存 |
| mall-nginx | 80 | 80 | Nginx反向代理 |
| mall-frontend | 80 | 3000 | 前端服务 |

## 📈 最近更新

### 购物车和订单系统 (2026-02-28)
- ✅ 完整的购物车管理功能
- ✅ 订单创建和支付流程
- ✅ 库存预占机制
- ✅ 商品快照功能
- ✅ 订单状态追踪

### 商品管理 (2026-02-20)
- ✅ 商品CRUD操作
- ✅ 商品分类管理
- ✅ 商品详情图片管理
- ✅ 最热商品推荐
- ✅ 商品评价系统

## 🤝 贡献指南

欢迎贡献代码!请遵循以下步骤:

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

如有问题或建议,欢迎通过以下方式联系:

- 提交 Issue
- 发送邮件至 your.email@example.com

## ⭐ Star History

如果这个项目对你有帮助,请给个 Star ⭐

---

<div align="center">

Made with ❤️ by Health Mall Team

</div>
