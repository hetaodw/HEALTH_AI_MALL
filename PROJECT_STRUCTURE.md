# 项目结构文档

```
d:\26bs/
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
│   │       │           │   └── WebConfig.java                # Web配置，注册认证拦截器和静态资源映射
│   │       │           ├── controller/
│   │       │           │   ├── AdminProductController.java   # 管理员商品管理接口，创建/删除商品
│   │       │           │   ├── AuthController.java           # 认证控制器，注册/登录/登出接口
│   │       │           │   ├── MerchantProductController.java # 商家商品管理，添加/修改/上下架商品
│   │       │           │   ├── OrderController.java          # 订单控制器，创建订单/查询订单详情
│   │       │           │   ├── ProductController.java        # 商品查询接口，列表/搜索/详情/热门商品
│   │       │           │   ├── UploadController.java         # 文件上传接口，图片上传
│   │       │           │   └── UserController.java           # 用户控制器，获取/更新用户信息/头像上传
│   │       │           ├── dto/
│   │       │           │   ├── AddProductRequest.java        # 添加商品请求DTO
│   │       │           │   ├── CreateOrderRequest.java       # 创建订单请求DTO
│   │       │           │   ├── LoginRequest.java             # 登录请求DTO
│   │       │           │   ├── LoginResponse.java            # 登录响应DTO，返回token和用户信息
│   │       │           │   ├── MerchantProductListResponse.java # 商家商品列表响应DTO
│   │       │           │   ├── MerchantProductRequest.java   # 商家商品请求DTO
│   │       │           │   ├── MerchantProductResponse.java  # 商家商品响应DTO
│   │       │           │   ├── OrderResponse.java            # 订单响应DTO
│   │       │           │   ├── PageResponse.java             # 分页响应DTO，包含列表和分页信息
│   │       │           │   ├── ProductDetailResponse.java    # 商品详情响应DTO
│   │       │           │   ├── ProductListItem.java          # 商品列表项DTO
│   │       │           │   └── RegisterRequest.java          # 注册请求DTO
│   │       │           ├── entity/
│   │       │           │   ├── HotProduct.java                # 热门商品实体，记录商品热度分数
│   │       │           │   ├── Order.java                     # 订单实体，包含订单状态/金额/收货信息
│   │       │           │   ├── Product.java                   # 商品实体，包含标题/价格/库存/状态
│   │       │           │   ├── ProductDetailsImage.java       # 商品详情图片实体
│   │       │           │   └── User.java                      # 用户实体，包含用户名/密码/角色/头像
│   │       │           ├── exception/
│   │       │           │   ├── BusinessException.java         # 业务异常类，封装错误码和消息
│   │       │           │   └── GlobalExceptionHandler.java    # 全局异常处理器，统一异常响应格式
│   │       │           ├── interceptor/
│   │       │           │   └── AuthInterceptor.java           # JWT认证拦截器，验证Token并提取用户ID
│   │       │           ├── repository/
│   │       │           │   ├── HotProductRepository.java      # 热门商品数据访问接口
│   │       │           │   ├── OrderRepository.java           # 订单数据访问接口，按用户/状态查询
│   │       │           │   ├── ProductDetailsImageRepository.java # 商品详情图片数据访问接口
│   │       │           │   ├── ProductRepository.java         # 商品数据访问接口，搜索/分类/热门查询
│   │       │           │   └── UserRepository.java            # 用户数据访问接口，按用户名查询
│   │       │           ├── service/
│   │       │           │   ├── AuthService.java               # 认证服务，注册/登录/密码加密
│   │       │           │   ├── FileUploadService.java         # 文件上传服务，图片存储/大小验证
│   │       │           │   ├── MerchantProductService.java    # 商家商品服务，商品CRUD操作
│   │       │           │   ├── OrderService.java              # 订单服务，创建订单/库存扣减
│   │       │           │   ├── ProductDetailService.java      # 商品详情服务，获取完整商品信息
│   │       │           │   ├── ProductService.java            # 商品服务，列表/搜索/分页查询
│   │       │           │   └── UserService.java               # 用户服务，获取/更新用户资料
│   │       │           ├── util/
│   │       │           │   └── JwtUtil.java                   # JWT工具类，生成/验证/解析Token
│   │       │           └── HealthMallApplication.java         # Spring Boot启动类
│   │       └── resources/
│   │           └── application.yml                            # 应用配置，数据库/Redis/JWT/文件上传配置
│   ├── Dockerfile                                             # 后端Docker构建文件
│   └── pom.xml                                                # Maven依赖配置，Spring Boot/MySQL/Redis/JWT
│
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── index.js                                       # Axios API封装，认证/商品/用户/商家接口
│   │   ├── components/
│   │   │   ├── AvatarUpload.vue                               # 头像上传组件
│   │   │   ├── Footer.vue                                     # 页面底部组件
│   │   │   ├── Header.vue                                     # 页面头部组件，导航/搜索/用户菜单
│   │   │   ├── Pagination.vue                                 # 分页组件
│   │   │   ├── ProductCard.vue                                # 商品卡片组件，展示商品缩略信息
│   │   │   └── ProductForm.vue                                # 商品表单组件，添加/编辑商品
│   │   ├── router/
│   │   │   └── index.js                                       # Vue Router路由配置，页面路由定义
│   │   ├── stores/
│   │   │   └── user.js                                        # Pinia用户状态管理，token/登录状态
│   │   ├── styles/
│   │   │   └── global.css                                     # 全局样式文件
│   │   ├── views/
│   │   │   ├── Home.vue                                       # 首页，热门商品展示
│   │   │   ├── Login.vue                                      # 登录页面
│   │   │   ├── MerchantDashboard.vue                          # 商家后台页面，商品管理
│   │   │   ├── ProductDetail.vue                              # 商品详情页面
│   │   │   ├── ProductList.vue                                # 商品列表页面，筛选/排序
│   │   │   ├── Profile.vue                                    # 个人中心页面
│   │   │   ├── Register.vue                                   # 注册页面
│   │   │   └── Search.vue                                     # 搜索页面
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
├── docs/
│   ├── API_DOCUMENTATION.md                                   # API接口文档
│   ├── database-schema.md                                     # 数据库结构文档
│   └── startguide.md                                          # 启动指南文档
│
├── .gitignore                                                 # Git忽略文件配置
├── README.md                                                  # 项目说明文档，部署说明
├── README_UI.md                                               # UI说明文档
├── RELEASE_v1.02.md                                           # 版本发布说明
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
