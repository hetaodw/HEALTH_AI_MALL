# 项目结构文档

```
d:\26bs/
├── .trae/
│   ├── documents/
│   │   └── 购物车到下单完整功能开发计划.md                      # 购物车功能开发计划文档
│   └── rules/
│       └── project_rules.md                                   # 项目规则配置
│
├── backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/
│   │       │       └── healthmall/
│   │       │           ├── common/
│   │       │           │   └── ApiResponse.java              # 统一API响应封装，包含code/msg/data字段
│   │       │           ├── config/
│   │       │           │   ├── CorsConfig.java               # 跨域配置，允许所有来源的跨域请求
│   │       │           │   ├── JacksonConfig.java            # Jackson JSON配置，日期格式化等
│   │       │           │   └── WebConfig.java                # Web配置，注册认证拦截器和静态资源映射
│   │       │           ├── controller/
│   │       │           │   ├── AddressController.java        # 收货地址管理接口，增删改查/设置默认
│   │       │           │   ├── AdminProductController.java   # 管理员商品管理接口，创建/删除商品
│   │       │           │   ├── AuthController.java           # 认证控制器，注册/登录/登出接口
│   │       │           │   ├── MerchantProductController.java # 商家商品管理，添加/修改/上下架商品
│   │       │           │   ├── OrderController.java          # 订单控制器，创建订单/查询/支付/取消
│   │       │           │   ├── ProductController.java        # 商品查询接口，列表/搜索/详情/热门商品
│   │       │           │   ├── ProductDescriptionController.java # 商品详情介绍接口，获取/创建/删除
│   │       │           │   ├── ProductReviewController.java  # 商品评价接口，获取/创建/删除评价
│   │       │           │   ├── UploadController.java         # 文件上传接口，图片上传
│   │       │           │   └── UserController.java           # 用户控制器，获取/更新用户信息/头像上传
│   │       │           ├── dto/
│   │       │           │   ├── AddProductRequest.java        # 添加商品请求DTO
│   │       │           │   ├── AddressRequest.java           # 地址请求DTO，收货人/电话/省市区/详细地址
│   │       │           │   ├── CreateOrderRequest.java       # 创建订单请求DTO，包含商品列表和地址ID
│   │       │           │   ├── LoginRequest.java             # 登录请求DTO
│   │       │           │   ├── LoginResponse.java            # 登录响应DTO，返回token和用户信息
│   │       │           │   ├── MerchantProductListResponse.java # 商家商品列表响应DTO
│   │       │           │   ├── MerchantProductRequest.java   # 商家商品请求DTO
│   │       │           │   ├── MerchantProductResponse.java  # 商家商品响应DTO
│   │       │           │   ├── OrderResponse.java            # 订单响应DTO，包含订单项和支付信息
│   │       │           │   ├── PageResponse.java             # 分页响应DTO，包含列表和分页信息
│   │       │           │   ├── ProductDescriptionResponse.java # 商品详情介绍响应DTO
│   │       │           │   ├── ProductDetailResponse.java    # 商品详情响应DTO
│   │       │           │   ├── ProductListItem.java          # 商品列表项DTO
│   │       │           │   ├── ProductReviewRequest.java     # 商品评价请求DTO，评分/标题/内容
│   │       │           │   ├── ProductReviewResponse.java    # 商品评价响应DTO
│   │       │           │   └── RegisterRequest.java          # 注册请求DTO
│   │       │           ├── entity/
│   │       │           │   ├── Address.java                   # 收货地址实体，省市区/详细地址/默认标识
│   │       │           │   ├── HotProduct.java                # 热门商品实体，记录商品热度分数
│   │       │           │   ├── Order.java                     # 订单实体，状态/金额/收货信息/支付过期时间
│   │       │           │   ├── OrderItem.java                 # 订单项实体，关联商品快照/数量/单价
│   │       │           │   ├── Payment.java                   # 支付记录实体，支付方式/状态/金额
│   │       │           │   ├── Product.java                   # 商品实体，标题/价格/库存/状态/评分
│   │       │           │   ├── ProductDescription.java        # 商品详情介绍实体，文字描述
│   │       │           │   ├── ProductDetailsImage.java       # 商品详情图片实体
│   │       │           │   ├── ProductReview.java             # 商品评价实体，评分/标题/内容/匿名标识
│   │       │           │   ├── ProductSnapshot.java           # 商品快照实体，下单时商品信息快照
│   │       │           │   ├── StockReservation.java          # 库存预占实体，订单库存预占/过期释放
│   │       │           │   └── User.java                      # 用户实体，用户名/密码/角色/头像
│   │       │           ├── exception/
│   │       │           │   ├── BusinessException.java         # 业务异常类，封装错误码和消息
│   │       │           │   └── GlobalExceptionHandler.java    # 全局异常处理器，统一异常响应格式
│   │       │           ├── interceptor/
│   │       │           │   └── AuthInterceptor.java           # JWT认证拦截器，验证Token并提取用户ID
│   │       │           ├── repository/
│   │       │           │   ├── AddressRepository.java         # 地址数据访问接口，按用户查询
│   │       │           │   ├── HotProductRepository.java      # 热门商品数据访问接口
│   │       │           │   ├── OrderItemRepository.java       # 订单项数据访问接口
│   │       │           │   ├── OrderRepository.java           # 订单数据访问接口，按用户/状态查询
│   │       │           │   ├── PaymentRepository.java         # 支付记录数据访问接口
│   │       │           │   ├── ProductDescriptionRepository.java # 商品详情介绍数据访问接口
│   │       │           │   ├── ProductDetailsImageRepository.java # 商品详情图片数据访问接口
│   │       │           │   ├── ProductRepository.java         # 商品数据访问接口，搜索/分类/热门查询
│   │       │           │   ├── ProductReviewRepository.java   # 商品评价数据访问接口
│   │       │           │   ├── ProductSnapshotRepository.java # 商品快照数据访问接口
│   │       │           │   ├── StockReservationRepository.java # 库存预占数据访问接口
│   │       │           │   └── UserRepository.java            # 用户数据访问接口，按用户名查询
│   │       │           ├── service/
│   │       │           │   ├── AddressService.java            # 地址服务，地址CRUD/设置默认
│   │       │           │   ├── AuthService.java               # 认证服务，注册/登录/密码加密
│   │       │           │   ├── FileUploadService.java         # 文件上传服务，图片存储/大小验证
│   │       │           │   ├── MerchantProductService.java    # 商家商品服务，商品CRUD操作
│   │       │           │   ├── OrderService.java              # 订单服务，创建订单/支付/取消/库存预占
│   │       │           │   ├── ProductDescriptionService.java # 商品详情介绍服务
│   │       │           │   ├── ProductDetailService.java      # 商品详情服务，获取完整商品信息
│   │       │           │   ├── ProductReviewService.java      # 商品评价服务，评价CRUD/评分统计
│   │       │           │   ├── ProductService.java            # 商品服务，列表/搜索/分页查询
│   │       │           │   ├── StockReservationService.java   # 库存预占服务，预占/确认/释放
│   │       │           │   └── UserService.java               # 用户服务，获取/更新用户资料
│   │       │           ├── task/
│   │       │           │   └── OrderScheduledTask.java        # 订单定时任务，超时订单取消/库存释放
│   │       │           ├── util/
│   │       │           │   ├── JwtUtil.java                   # JWT工具类，生成/验证/解析Token
│   │       │           │   └── SnowflakeIdGenerator.java      # 雪花算法ID生成器，生成唯一订单号
│   │       │           └── HealthMallApplication.java         # Spring Boot启动类
│   │       └── resources/
│   │           ├── db/
│   │           │   └── order_schema.sql                       # 订单相关数据库表结构SQL
│   │           └── application.yml                            # 应用配置，数据库/Redis/JWT/文件上传配置
│   ├── Dockerfile                                             # 后端Docker构建文件
│   └── pom.xml                                                # Maven依赖配置，Spring Boot/MySQL/Redis/JWT
│
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── index.js                                       # Axios API封装，认证/商品/用户/商家/订单/地址接口
│   │   ├── components/
│   │   │   ├── AvatarUpload.vue                               # 头像上传组件
│   │   │   ├── Footer.vue                                     # 页面底部组件
│   │   │   ├── Header.vue                                     # 页面头部组件，导航/搜索/用户菜单/购物车入口
│   │   │   ├── Pagination.vue                                 # 分页组件
│   │   │   ├── ProductCard.vue                                # 商品卡片组件，展示商品缩略信息
│   │   │   └── ProductForm.vue                                # 商品表单组件，添加/编辑商品
│   │   ├── router/
│   │   │   └── index.js                                       # Vue Router路由配置，页面路由/权限守卫
│   │   ├── stores/
│   │   │   └── user.js                                        # Pinia用户状态管理，token/登录状态
│   │   ├── styles/
│   │   │   └── global.css                                     # 全局样式文件，拟物化设计风格
│   │   ├── utils/
│   │   │   └── dateFormatter.js                               # 日期时间格式化工具函数
│   │   ├── views/
│   │   │   ├── Cart.vue                                       # 购物车页面，商品选择/数量修改/结算
│   │   │   ├── Home.vue                                       # 首页，热门商品展示/导航/广告栏
│   │   │   ├── Login.vue                                      # 登录页面
│   │   │   ├── MerchantDashboard.vue                          # 商家后台页面，商品管理
│   │   │   ├── OrderConfirm.vue                               # 订单确认页面，地址选择/支付方式/订单创建
│   │   │   ├── ProductDetail.vue                              # 商品详情页面，商品信息/评价展示
│   │   │   ├── ProductList.vue                                # 商品列表页面，筛选/排序/分页
│   │   │   ├── Profile.vue                                    # 个人中心页面，信息/地址/订单管理
│   │   │   ├── Register.vue                                   # 注册页面，用户/商家身份选择
│   │   │   └── Search.vue                                     # 搜索页面，关键词搜索/结果展示
│   │   ├── App.vue                                            # 根组件，Header/Footer布局
│   │   └── main.js                                            # 入口文件，Vue应用初始化
│   ├── Dockerfile                                             # 前端Docker构建文件
│   ├── index.html                                             # HTML入口文件
│   ├── nginx.conf                                             # 前端Nginx配置
│   ├── package.json                                           # npm依赖配置，Vue/Vite/Pinia/Axios
│   └── vite.config.js                                         # Vite构建配置，代理/端口设置
│
├── health_mall_ui/
│   └── main                                                   # 旧版UI目录
│
├── nginx/
│   ├── conf.d/
│   │   └── default.conf                                       # Nginx站点配置
│   └── nginx.conf                                             # Nginx主配置文件
│
├── database/
│   └── schema_updates.sql                                     # 数据库结构更新SQL脚本
│
├── docs/
│   ├── API_DOCUMENTATION.md                                   # API接口文档
│   ├── PAYMENT_ARCHITECTURE.md                                # 支付功能技术文档
│   ├── database-schema.md                                     # 数据库结构文档
│   └── startguide.md                                          # 启动指南文档
│
├── .gitignore                                                 # Git忽略文件配置
├── PROJECT_STRUCTURE.md                                       # 项目结构文档（本文件）
├── README.md                                                  # 项目说明文档，部署说明
├── README_UI.md                                               # UI说明文档
├── START_GUIDE.md                                             # 启动指南
├── Start.sql                                                  # 数据库初始化SQL脚本
├── UpdateSchema.sql                                           # 数据库结构更新SQL脚本
├── docker-compose.yml                                         # Docker编排配置，MySQL/Redis/后端/前端
├── docker-compose.override.yml                                # Docker覆盖配置，代理设置
├── test.html                                                  # 测试页面
├── test.sql                                                   # 测试SQL脚本
├── test_data.sql                                              # 测试数据SQL脚本
└── update_user_table.sql                                      # 用户表更新SQL脚本
```

## 核心模块说明

### 1. 用户认证模块
- **AuthController**: 用户注册、登录、登出
- **AuthService**: 密码加密、Token生成
- **JwtUtil**: JWT Token生成与验证
- **AuthInterceptor**: 请求拦截，验证用户身份

### 2. 商品模块
- **ProductController**: 商品列表、搜索、详情、分类查询
- **ProductService**: 商品业务逻辑
- **ProductDescription**: 商品详情介绍（文字描述）
- **ProductReview**: 商品评价功能
- **HotProduct**: 热门商品推荐

### 3. 订单模块
- **OrderController**: 订单创建、查询、支付、取消
- **OrderService**: 订单业务逻辑
- **OrderItem**: 订单项，关联商品快照
- **ProductSnapshot**: 商品快照，记录下单时商品信息
- **StockReservation**: 库存预占，防止超卖
- **OrderScheduledTask**: 定时任务，处理超时订单

### 4. 支付模块
- **Payment**: 支付记录，支持支付宝/微信/余额
- **PaymentStatus**: 支付状态（待支付/成功/失败/退款）
- 模拟支付实现，预留真实支付接口

### 5. 购物车模块
- **Cart.vue**: 购物车页面
- **OrderConfirm.vue**: 订单确认页面
- 支持商品选择、数量修改、结算

### 6. 用户中心模块
- **UserController**: 用户信息管理
- **AddressController**: 收货地址管理
- **Profile.vue**: 个人中心页面

### 7. 商家模块
- **MerchantProductController**: 商家商品管理
- **MerchantDashboard.vue**: 商家后台页面

## 数据库表结构

| 表名 | 说明 |
|------|------|
| users | 用户信息表 |
| products | 商品基础信息表 |
| product_details_images | 商品详情图片表 |
| product_descriptions | 商品详情介绍表 |
| product_reviews | 商品评价表 |
| product_snapshots | 商品快照表 |
| hot_products | 热门商品表 |
| orders | 订单表 |
| order_items | 订单项表 |
| payments | 支付记录表 |
| stock_reservations | 库存预占表 |
| addresses | 收货地址表 |

## 技术栈

### 后端
- Spring Boot 3.x
- Spring Data JPA
- MySQL 8.0
- Redis
- JWT认证
- 雪花算法ID生成

### 前端
- Vue 3 + Composition API
- Vue Router
- Pinia
- Axios
- Vite
- 拟物化设计风格

### 部署
- Docker
- Docker Compose
- Nginx反向代理
