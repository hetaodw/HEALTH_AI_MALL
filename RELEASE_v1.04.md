# 健康商城系统 v1.04 发布报告

**发布日期**: 2026-02-13  
**版本号**: v1.04  
**Git标签**: `v1.04`  

---

## 更新摘要

本次更新主要重构了 Docker 构建配置，支持通过代理服务器拉取镜像和构建项目，同时修复了时间序列化问题。

---

## 主要更新内容

### 1. Docker 代理配置重构 🐳

**问题描述**:
- 在国内网络环境下无法直接访问 Docker Hub
- Maven 和 npm 依赖下载缓慢或失败

**解决方案**:
- **docker-compose.override.yml**: 更新构建参数，支持通过代理服务器 (`http://192.168.31.165:7897`) 构建
- **backend/Dockerfile**: 添加 `ARG HTTP_PROXY` 和 `ARG HTTPS_PROXY` 参数，在构建阶段使用代理
- **frontend/Dockerfile**: 同样添加代理参数支持，优化 npm 安装流程

**变更详情**:
```yaml
# docker-compose.override.yml
args:
  - HTTP_PROXY=http://192.168.31.165:7897
  - HTTPS_PROXY=http://192.168.31.165:7897
```

```dockerfile
# backend/Dockerfile & frontend/Dockerfile
ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
```

### 2. 时间序列化配置修复 ⏰

**新增文件**:
- `backend/src/main/java/com/healthmall/config/JacksonConfig.java`

**功能**:
- 配置 Jackson 序列化/反序列化 LocalDateTime 类型
- 统一使用 `yyyy-MM-dd HH:mm:ss` 格式
- 修复前后端时间格式不一致问题

### 3. 购物车到下单流程优化 🛒

**新增功能**:
- 购物车页面 (`Cart.vue`)
- 订单确认页面 (`OrderConfirm.vue`)
- 地址管理功能
- 库存预占机制

---

## 文件变更列表

### 后端变更 (Backend)
```
backend/src/main/java/com/healthmall/config/JacksonConfig.java (新增)
backend/Dockerfile
```

### 前端变更 (Frontend)
```
frontend/src/views/Cart.vue (新增)
frontend/src/views/OrderConfirm.vue (新增)
frontend/src/utils/ (新增工具函数)
frontend/Dockerfile
```

### 配置变更
```
docker-compose.override.yml
```

### 文档变更
```
RELEASE_v1.04.md (新增)
```

---

## 部署说明

### 使用 Docker Compose 部署

```bash
# 拉取最新代码
git pull
git checkout v1.04

# 构建并启动服务
docker-compose down
docker-compose up -d --build
```

### 代理配置说明

如果需要在其他环境中使用不同的代理，修改 `docker-compose.override.yml`:

```yaml
services:
  mall-backend:
    build:
      args:
        - HTTP_PROXY=http://your-proxy:port
        - HTTPS_PROXY=http://your-proxy:port
  
  mall-frontend:
    build:
      args:
        - HTTP_PROXY=http://your-proxy:port
        - HTTPS_PROXY=http://your-proxy:port
```

### 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| mall-nginx | 80 | 前端入口 |
| mall-backend | 8080 | 后端API |
| mall-mysql | 4000 | 数据库 |
| mall-redis | 6379 | 缓存 |
| mall-frontend | 3000 | 前端开发服务器 |

---

## 技术细节

### Docker 构建代理原理

1. **BuildKit 参数传递**: 使用 `ARG` 指令在 Dockerfile 中定义代理参数
2. **环境变量设置**: 在构建阶段将代理参数设置为环境变量
3. **工具链识别**: Maven 和 npm 自动识别 `HTTP_PROXY`/`HTTPS_PROXY` 环境变量

### Jackson 时间序列化配置

```java
@Bean
public ObjectMapper objectMapper() {
    ObjectMapper mapper = new ObjectMapper();
    JavaTimeModule javaTimeModule = new JavaTimeModule();
    
    // 序列化
    javaTimeModule.addSerializer(LocalDateTime.class, 
        new LocalDateTimeSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    
    // 反序列化
    javaTimeModule.addDeserializer(LocalDateTime.class, 
        new LocalDateTimeDeserializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    
    mapper.registerModule(javaTimeModule);
    return mapper;
}
```

---

## 已知问题

无

---

## 后续计划

- v1.05: 添加支付功能
- v1.06: 添加商品搜索和筛选功能

---

## 贡献者

- 开发团队

---

**注意**: 本次更新主要涉及构建配置，不影响数据库结构，可直接部署。
