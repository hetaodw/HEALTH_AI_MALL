# 项目启动指南

本文档记录了健康商城系统从 0 到 1 的启动经验，包括遇到的问题和解决方案。

---

## 目录

1. [环境准备](#环境准备)
2. [Docker 构建踩坑记录](#docker-构建踩坑记录)
3. [代理配置详解](#代理配置详解)
4. [常用命令](#常用命令)
5. [故障排查](#故障排查)

---

## 环境准备

### 必需软件

| 软件 | 版本 | 说明 |
|------|------|------|
| Docker Desktop | 4.x+ | Windows 需要开启 WSL2 后端 |
| Docker Compose | 2.x+ | 通常随 Docker Desktop 安装 |
| PowerShell | 5.1+ | Windows 构建脚本 |
| Git | 任意 | 克隆代码仓库 |

### 验证安装

```powershell
# 检查 Docker 版本
docker --version
docker-compose --version

# 检查 Docker 是否正常运行
docker ps
```

---

## Docker 构建踩坑记录

### 问题 1：Docker Desktop 全局代理导致构建失败

**现象**：
```
npm error code ECONNREFUSED
npm error syscall connect
npm error errno ECONNREFUSED
npm error FetchError: request to https://registry.npmjs.org/xxx failed, 
reason: connect ECONNREFUSED 127.0.0.1:7897
```

**原因**：
Docker Desktop 配置了全局代理 `127.0.0.1:7897`，这个设置会强制注入到所有容器的构建过程中。但容器内的 `127.0.0.1` 指向的是容器本身，而不是宿主机的代理服务。

**解决方案**：

在 [frontend/Dockerfile](../frontend/Dockerfile) 中强制清除代理环境变量：

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

# 强制清除环境变量和 npm 配置
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy && \
    npm config set registry https://registry.npmjs.org/ && \
    npm install --no-audit --progress=false

COPY . .

RUN npm run build
```

关键点：
1. 添加 `# syntax=docker/dockerfile:1` 启用 BuildKit 语法
2. 使用 `unset` 清除所有可能的代理环境变量
3. 显式设置 npm registry 为官方源

**构建命令**：
```powershell
# 必须清空代理环境变量
$env:HTTP_PROXY=""; $env:HTTPS_PROXY=""
docker-compose build --no-cache
```

---

### 问题 2：Maven 构建参数错误

**现象**：
```
Unrecognized option: -T
Error: Could not create the Java Virtual Machine.
```

**原因**：
`MAVEN_OPTS` 中使用了 `-T 1C` 参数（并行构建），但这个参数应该传给 `mvn` 命令而不是 JVM。

**解决方案**：

从 docker-compose.yml 中移除 `MAVEN_OPTS` 的 `-T` 参数：

```yaml
# 错误
- MAVEN_OPTS=-Dmaven.test.skip=true -Dmaven.compile.fork=true -T 1C

# 正确
# 直接移除 MAVEN_OPTS，使用默认配置
```

---

### 问题 3：Docker 镜像拉取超时

**现象**：
```
failed to solve: failed to fetch anonymous token: 
Get "https://auth.docker.io/token": dial tcp x.x.x.x:443: i/o timeout
```

**原因**：
网络环境无法直接访问 Docker Hub。

**解决方案**：

方案 A - 配置 Docker Desktop 代理（推荐）：
1. 打开 Docker Desktop → Settings → Resources → Proxies
2. 设置 Web Server (HTTP): `http://192.168.x.x:7897`
3. 设置 Web Server (HTTPS): `http://192.168.x.x:7897`
4. 点击 Apply & Restart

方案 B - 使用国内镜像源：
在 Docker Desktop → Settings → Docker Engine 中添加：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

---

### 问题 4：npm 安装超时

**现象**：
```
npm error code ETIMEDOUT
npm error syscall connect
npm error errno ETIMEDOUT
```

**解决方案**：

在 Dockerfile 中配置淘宝镜像源：

```dockerfile
RUN npm config set registry https://registry.npmmirror.com && \
    npm install --no-audit --progress=false
```

或使用官方源但清除代理：
```dockerfile
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy && \
    npm config set registry https://registry.npmjs.org/ && \
    npm install --no-audit --progress=false
```

---

## 代理配置详解

### 场景 1：需要代理访问外网

如果你的网络环境需要代理才能访问 Docker Hub 和 npm registry：

**步骤 1**：在 Clash/代理软件中开启 "Allow LAN"

**步骤 2**：获取宿主机局域网 IP
```powershell
(Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { $_.IPAddress -like "192.168.*" } | 
    Select-Object -First 1).IPAddress
```

**步骤 3**：配置 Docker Desktop 代理
- HTTP Proxy: `http://192.168.x.x:7897`
- HTTPS Proxy: `http://192.168.x.x:7897`

**步骤 4**：修改 Dockerfile 使用代理
```dockerfile
ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
RUN npm config set proxy $HTTP_PROXY && \
    npm config set https-proxy $HTTPS_PROXY && \
    npm install
```

### 场景 2：不需要代理（本项目的最终方案）

如果你的网络环境可以直接访问外网，或者 Docker Desktop 配置了镜像加速器：

**步骤 1**：清空 Docker Desktop 代理设置
- Settings → Resources → Proxies → 清空所有字段

**步骤 2**：使用当前配置（已清除代理）

**步骤 3**：构建时清空环境变量
```powershell
$env:HTTP_PROXY=""; $env:HTTPS_PROXY=""
docker-compose build
```

---

## 常用命令

### 完整启动流程

```powershell
# 1. 进入项目目录
cd d:\26bs

# 2. 清空代理环境变量（重要！）
$env:HTTP_PROXY=""
$env:HTTPS_PROXY=""

# 3. 构建所有服务
docker-compose build

# 4. 启动所有服务
docker-compose up -d

# 5. 查看服务状态
docker-compose ps

# 6. 查看日志
docker-compose logs -f
```

### 重新构建单个服务

```powershell
# 清空代理
$env:HTTP_PROXY=""; $env:HTTPS_PROXY=""

# 停止并删除容器
docker-compose stop mall-frontend
docker-compose rm -f mall-frontend

# 重新构建（不使用缓存）
docker-compose build --no-cache mall-frontend

# 启动
docker-compose up -d mall-frontend

# 查看日志
docker logs -f mall-frontend
```

### 清理 Docker 环境

```powershell
# 停止所有容器
docker-compose down

# 清理未使用的镜像、容器、网络、卷
docker system prune -af

# 清理构建缓存
docker builder prune -af
```

---

## 故障排查

### 排查清单

1. **Docker Desktop 是否运行？**
   ```powershell
   docker info
   ```

2. **代理环境变量是否已清空？**
   ```powershell
   Get-ChildItem Env: | Where-Object { $_.Name -like "*PROXY*" }
   ```

3. **Docker Desktop 代理设置是否已清空？**
   - 检查 Settings → Resources → Proxies

4. **端口是否被占用？**
   ```powershell
   netstat -ano | findstr :8080
   netstat -ano | findstr :3000
   netstat -ano | findstr :80
   ```

5. **查看详细构建日志**
   ```powershell
   docker-compose build --progress=plain --no-cache 2>&1 | Tee-Object build.log
   ```

### 常见问题速查

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| `ECONNREFUSED 127.0.0.1:7897` | Docker Desktop 全局代理残留 | 清空 Dockerfile 中的代理配置 |
| `i/o timeout` | 无法访问 Docker Hub | 配置镜像加速器或代理 |
| `port is already allocated` | 端口被占用 | 停止占用端口的进程或修改端口映射 |
| `Cannot connect to the Docker daemon` | Docker Desktop 未运行 | 启动 Docker Desktop |
| `mvn command not found` | 基础镜像问题 | 检查 Dockerfile 中的 FROM 镜像 |

---

## 项目结构

```
26bs/
├── backend/              # Java Spring Boot 后端
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/
├── frontend/             # Vue.js 前端
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── nginx/                # Nginx 配置
│   ├── nginx.conf
│   └── conf.d/
├── docs/                 # 文档
│   ├── database-schema.md    # 数据库结构说明
│   ├── API_DOCUMENTATION.md  # API 文档
│   └── startguide.md         # 本文件
├── docker-compose.yml    # Docker Compose 配置
├── Start.sql            # 数据库初始化脚本
└── README.md            # 项目说明
```

---

## 参考资料

- [Docker Desktop 官方文档](https://docs.docker.com/desktop/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [npm 代理配置](https://docs.npmjs.com/cli/v8/commands/npm-config)
- [Maven 镜像配置](https://maven.apache.org/guides/mini/guide-mirror-settings.html)

---

*最后更新：2026-01-30*
*作者：AI Assistant*
