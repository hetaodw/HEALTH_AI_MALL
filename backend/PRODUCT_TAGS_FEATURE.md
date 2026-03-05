# 商品标签AI生成功能 - 后端集成文档

## 项目简介

基于Qwen3.5-2B模型的商品自动标签生成系统，集成到健康商城后端。通过AI模型自动为商品生成标签，支持定时批量处理和手动更新。

## 重要提示

⚠️ **依赖要求**: 需要Python AI服务运行在 `http://localhost:5000`

✅ **AI服务**: 请先启动 ai-service，确保 `/api/generate-tags` 接口可用

启动AI服务:
```bash
cd ai-service
# Windows
start.bat
# Linux/Mac
./start.sh
```

## 后端服务

### 快速启动

**Windows:**
```bash
cd backend
mvn spring-boot:run
```

**Docker:**
```bash
docker-compose up -d mall-backend
```

### 配置说明

在 `backend/src/main/resources/application.yml` 中配置：

```yaml
ai:
  service:
    url: http://localhost:5000      # AI服务地址
    timeout: 30000                   # 超时时间（毫秒）

product:
  tag:
    batch:
      size: 50                        # 定时任务每批处理数量
    task:
      enabled: true                     # 是否启用定时任务
      cron: "0 0 */2 * * ?"        # Cron表达式（每2小时执行一次）
```

### API接口

服务启动后，可以通过以下地址访问：

- **后端服务**: http://localhost:8080
- **API基础路径**: http://localhost:8080/v1
- **API文档**: [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)

### 主要接口

#### 1. 为商品生成标签

```bash
POST /v1/products/tags/{productId}/generate
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

#### 2. 批量生成商品标签

```bash
POST /v1/products/tags/batch/generate
Authorization: Bearer {token}
Content-Type: application/json

{
  "productIds": [1, 2, 3, 4, 5]
}

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "successCount": 4,
    "failedCount": 1,
    "failedProductIds": [5],
    "message": "批量生成完成：成功4个，失败1个"
  }
}
```

#### 3. 获取商品标签

```bash
GET /v1/products/tags/{productId}

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

#### 4. 手动更新商品标签

```bash
PUT /v1/products/tags/{productId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "tags": ["维生素", "增强免疫力", "抗氧化"]
}

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": null
}
```

#### 5. 获取热门标签

```bash
GET /v1/products/tags/popular?limit=20

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {"tag": "维生素", "count": 150},
    {"tag": "增强免疫力", "count": 120},
    {"tag": "抗氧化", "count": 98}
  ]
}
```

#### 6. 按标签搜索商品

```bash
GET /v1/products/tags/search?tags=维生素&tags=增强免疫力&page=1&size=10

Response:
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "天然维C片500mg",
        "coverUrl": "http://example.com/product1.jpg",
        "price": 59.90,
        "stock": 100,
        "tags": ["维生素", "增强免疫力", "抗氧化"]
      }
    ],
    "total": 50
  }
}
```

## 项目结构

```
backend/src/main/java/com/healthmall/
├── controller/
│   └── ProductTagController.java        # 商品标签API控制器
├── service/
│   ├── AiTagGenerator.java           # AI模型调用服务
│   └── ProductTagService.java        # 标签管理服务
├── task/
│   └── ProductTagScheduledTask.java  # 定时任务
├── dto/
│   ├── BatchGenerateRequest.java      # 批量生成请求
│   ├── BatchGenerateResponse.java     # 批量生成响应
│   ├── TagStatistics.java           # 标签统计
│   └── UpdateTagsRequest.java      # 更新标签请求
├── entity/
│   └── Product.java                # 商品实体（新增tags相关方法）
├── repository/
│   └── ProductRepository.java       # 数据访问层（新增查询方法）
└── resources/
    └── application.yml             # 配置文件（新增AI服务配置）
```

## 快速开始

### 1. 数据库迁移

```bash
# 执行数据库迁移脚本
mysql -u root -p health_mall_system < database/add_product_tags_fields.sql
```

**迁移内容**:
- 添加 `need_regenerate_tags` 字段到 `products` 表
- 添加索引优化查询性能

### 2. 启动AI服务

```bash
cd ai-service
# Windows
start.bat
# Linux/Mac
./start.sh

# 验证服务
curl http://localhost:5000/health
```

### 3. 启动后端服务

```bash
cd backend
# 方式1: Maven直接运行
mvn spring-boot:run

# 方式2: Docker
docker-compose up -d mall-backend

# 方式3: 打包后运行
mvn clean package
java -jar target/health-mall-backend-1.0.0.jar
```

### 4. 测试API

```bash
# 测试为商品生成标签
curl -X POST http://localhost:8080/v1/products/tags/1/generate \
  -H "Authorization: Bearer {merchant_token}"

# 测试获取热门标签
curl -X GET "http://localhost:8080/v1/products/tags/popular?limit=10"
```

## 功能特性

### 自动生成标签

- **新增商品**: 商品添加成功后自动调用AI生成标签
- **降级处理**: AI调用失败不影响商品创建流程
- **异步处理**: 标签生成失败仅记录日志，不阻塞业务

### 智能更新标签

- **变更检测**: 监控商品标题和描述变化
- **标记机制**: 变化时标记 `need_regenerate_tags = true`
- **批量处理**: 定时任务批量处理待重新生成的商品

### 定时任务

- **默认频率**: 每2小时执行一次
- **批次大小**: 每次处理50个商品（可配置）
- **可配置**: 支持启用/禁用和自定义Cron表达式

### 标签管理

- **手动更新**: 商家可手动修改商品标签
- **标签搜索**: 支持按标签搜索商品
- **热门统计**: 提供热门标签排行榜
- **批量操作**: 支持批量生成标签

## 数据存储

### features字段格式

**旧格式**（已废弃）:
```json
{
  "brand": "健康品牌",
  "specification": "500mg/片",
  "origin": "中国"
}
```

**新格式**（当前使用）:
```json
["维生素", "增强免疫力", "抗氧化", "天然原料"]
```

### need_regenerate_tags字段

- **类型**: TINYINT(1)
- **默认值**: 0
- **用途**: 标记商品是否需要重新生成标签
- **触发条件**: 商品标题或描述修改时设置为1
- **重置条件**: 标签生成成功后设置为0

## 技术栈

- Spring Boot
- Spring Data JPA
- Spring Scheduling
- FastAPI (Python AI服务)
- Qwen3.5-2B (AI模型)
- MySQL

## 测试账号

使用以下测试账号进行API测试：

### 商家账号
- 用户名: `testmerchant1`
- 密码: `Test123456`

### 用户账号
- 用户名: `testuser1`
- 密码: `Test123456`

## 故障排查

### AI服务连接失败

**问题**: `Connection refused` 或 `Timeout`

**解决方案**:
1. 检查AI服务是否启动: `curl http://localhost:5000/health`
2. 检查配置文件中的AI服务地址是否正确
3. 检查防火墙设置

### 标签生成失败

**问题**: 返回空标签或生成失败

**解决方案**:
1. 检查AI服务日志
2. 确认模型是否正确加载
3. 检查商品标题和描述是否为空

### 定时任务不执行

**问题**: 标签未自动更新

**解决方案**:
1. 检查 `product.tag.task.enabled` 配置
2. 检查Cron表达式是否正确
3. 查看后端日志确认任务是否启动

## API文档

详细API文档请参考: [API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)

## 许可证

MIT License
