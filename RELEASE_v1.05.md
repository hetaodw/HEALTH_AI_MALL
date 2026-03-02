# 版本的变更记录

## v1.05 (2026-03-02)

### 新增功能

#### 商品详情介绍模块
- 新增 `product_descriptions` 表，存储商品详细文字介绍
- 新增 `ProductDescription` 实体类
- 新增 `ProductDescriptionRepository` 持久层接口
- 新增 `ProductDescriptionService` 服务层
- 新增 `ProductDescriptionController` 控制器，提供商品详情介绍CRUD接口
- 新增 `ProductDescriptionResponse` DTO

#### 商品评价模块
- 新增 `product_reviews` 表，存储商品评价信息（评分、标题、内容）
- 新增 `ProductReview` 实体类
- 新增 `ProductReviewRepository` 持久层接口
- 新增 `ProductReviewService` 服务层
- 新增 `ProductReviewController` 控制器，提供评价查询和提交接口
- 新增 `ProductReviewRequest` 和 `ProductReviewResponse` DTO

### 功能优化
- `ProductListItem` 新增 `reviewCount` 和 `avgRating` 字段
- `ProductDetailResponse` 新增评价相关字段
- 优化前端商品详情页，集成评价展示功能

### 文档更新
- 更新 `PROJECT_STRUCTURE.md` 项目结构文档
- 更新 `README.md` 部署说明文档
- 更新 `README_UI.md` UI说明文档
- 更新 `docs/API_DOCUMENTATION.md` API文档
- 更新 `docs/database-schema.md` 数据库文档

### 数据库变更
- 新增 `database/schema_updates.sql` 脚本，包含新建表和索引

---

## 历史版本

### v1.04 (之前版本)
- 购物车功能开发
- 订单管理功能
- 支付功能
