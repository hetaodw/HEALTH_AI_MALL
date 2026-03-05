# AI服务后端文档

## 概述

AI服务后端基于FastAPI框架，使用Qwen3.5-2B模型为商品生成标签。该服务提供RESTful API接口，可以被其他服务调用以实现自动化的商品标签生成功能。

## 目录

- [环境要求](#环境要求)
- [安装步骤](#安装步骤)
- [配置说明](#配置说明)
- [启动服务](#启动服务)
- [API接口](#api接口)
- [测试指南](#测试指南)
- [故障排查](#故障排查)

## 环境要求

### 硬件要求

- **CPU**: 4核及以上
- **内存**: 16GB及以上（推荐32GB）
- **GPU**: NVIDIA GPU（可选，用于加速推理）
  - CUDA 11.8+
  - 显存8GB及以上

### 软件要求

- **操作系统**: Windows 10/11, Linux, macOS
- **Python**: 3.8+
- **依赖包**: 见 [requirements.txt](requirements.txt)

## 安装步骤

### 1. 克隆项目

```bash
cd D:\26bs\ai-service
```

### 2. 创建虚拟环境

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**Linux/macOS:**
```bash
python -m venv venv
source venv/bin/activate
```

### 3. 安装依赖

```bash
pip install -r requirements.txt
```

### 4. 下载模型

模型已下载到 `models/qwen2.5-3b-instruct` 目录。

如果需要重新下载，请参考 [MODEL_DOWNLOAD_GUIDE.md](MODEL_DOWNLOAD_GUIDE.md)。

## 配置说明

配置文件位于 `config/model_config.yaml`。

### 主要配置项

```yaml
model:
  local_path: "models/qwen2.5-3b-instruct"  # 模型路径
  max_new_tokens: 512                        # 最大生成token数
  temperature: 0.7                          # 温度参数
  top_p: 0.9                                # top-p采样
  top_k: 50                                 # top-k采样

server:
  host: "0.0.0.0"                           # 监听地址
  port: 5001                               # 监听端口
  workers: 1                               # 工作进程数
```

## 启动服务

### 方式一：使用启动脚本（推荐）

**Windows:**
```bash
start.bat
```

**Linux/macOS:**
```bash
chmod +x start.sh
./start.sh
```

### 方式二：直接运行Python

```bash
python app.py
```

### 验证服务启动

服务启动后，访问以下地址验证：

- **健康检查**: http://localhost:5001/health
- **API文档**: http://localhost:5001/docs

## API接口

### 1. 健康检查

检查服务运行状态和模型加载情况。

**接口**: `GET /health`

**请求示例**:
```bash
curl http://localhost:5001/health
```

**响应示例**:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cuda:0"
}
```

### 2. 生成标签

根据商品信息生成标签。

**接口**: `POST /api/generate-tags`

**Content-Type**: `application/json`

**请求参数**:
```json
{
  "prompt": "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：天然维C片500mg\n商品描述：富含维生素 C，增强免疫力，抗氧化\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]"
}
```

**请求示例**:
```bash
curl -X POST http://localhost:5001/api/generate-tags \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：天然维C片500mg\n商品描述：富含维生素 C，增强免疫力，抗氧化\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]"
  }'
```

**响应示例**:
```json
{
  "tags": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

**响应字段说明**:
- `tags`: 生成的标签列表（字符串数组）

## 测试指南

### 自动化测试

使用提供的测试脚本进行自动化测试：

```bash
python test_api.py
```

测试脚本会自动测试以下内容：
1. 健康检查接口
2. 标签生成接口（多个测试用例）

### 手动测试

#### 测试健康检查

```bash
curl http://localhost:5001/health
```

#### 测试标签生成

```bash
curl -X POST http://localhost:5001/api/generate-tags \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：天然维C片500mg\n商品描述：富含维生素 C，增强免疫力，抗氧化\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]"
  }'
```

### 使用Swagger UI测试

访问 http://localhost:5001/docs 可以在浏览器中使用Swagger UI进行交互式测试。

## 集成到Java后端

Java后端已经集成了AI服务调用功能，相关代码位于：

- [AiTagGenerator.java](../backend/src/main/java/com/healthmall/service/AiTagGenerator.java)

### 配置

在 `application.yml` 中配置AI服务地址：

```yaml
ai:
  service:
    url: http://localhost:5001
    timeout: 30000
```

### 使用示例

```java
@Autowired
private AiTagGenerator aiTagGenerator;

public void generateProductTags(String title, String description) {
    List<String> tags = aiTagGenerator.generateTags(title, description);
    // 处理生成的标签
}
```

## 故障排查

### 问题1: 服务无法启动

**症状**: 运行启动脚本后服务立即退出

**解决方案**:
1. 检查虚拟环境是否正确激活
2. 检查依赖包是否完整安装
3. 查看日志文件 `logs/ai_service.log`

### 问题2: 模型加载失败

**症状**: 启动时提示"模型加载失败"

**解决方案**:
1. 确认模型文件存在于 `models/qwen2.5-3b-instruct` 目录
2. 检查磁盘空间是否充足
3. 如果使用GPU，确认CUDA版本兼容

### 问题3: 标签生成超时

**症状**: 请求超时或响应时间过长

**解决方案**:
1. 增加 `application.yml` 中的 `ai.service.timeout` 配置
2. 检查服务器资源使用情况
3. 考虑使用GPU加速

### 问题4: 生成的标签质量不佳

**症状**: 标签不准确或不相关

**解决方案**:
1. 调整 `model_config.yaml` 中的 `temperature` 参数
2. 优化prompt模板
3. 考虑使用微调后的模型

## 性能优化

### 使用GPU加速

如果系统有NVIDIA GPU，可以启用GPU加速：

1. 安装CUDA Toolkit
2. 安装GPU版本的PyTorch
3. 模型会自动检测并使用GPU

### 批量处理

对于大量商品，建议使用批量处理接口（待实现）。

### 缓存策略

可以考虑实现标签缓存机制，避免重复生成相同商品的标签。

## 日志

日志文件位于 `logs/` 目录：

- `ai_service.log`: AI服务主日志
- `text_tagger.log`: 标签提取日志

## 项目结构

```
ai-service/
├── app.py                 # FastAPI应用主文件
├── config/
│   ├── model_config.yaml  # 模型配置
│   └── lora_finetune_config.yaml  # LoRA微调配置
├── inference/
│   └── text_tagger.py     # 标签提取脚本
├── scripts/               # 各种脚本
├── training/              # 训练相关代码
├── utils/                 # 工具函数
├── models/                # 模型文件目录
├── data/                  # 数据目录
├── logs/                  # 日志目录
├── requirements.txt       # Python依赖
├── start.bat             # Windows启动脚本
├── start.sh              # Linux/macOS启动脚本
└── test_api.py           # API测试脚本
```

## 相关文档

- [GPU_SETUP.md](GPU_SETUP.md) - GPU环境配置
- [INSTALL_GUIDE.md](INSTALL_GUIDE.md) - 安装指南
- [MODEL_DOWNLOAD_GUIDE.md](MODEL_DOWNLOAD_GUIDE.md) - 模型下载指南
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 项目结构说明

## 技术支持

如遇到问题，请查看：
1. 日志文件 `logs/ai_service.log`
2. 相关文档
3. GitHub Issues（如果有）

## 更新日志

### v1.0.0 (2026-03-04)

- 初始版本发布
- 实现基础标签生成功能
- 提供RESTful API接口
- 支持健康检查
- 提供测试脚本
