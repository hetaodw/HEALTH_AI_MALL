# AI Service - 商品标签自动标注系统

## 项目简介

基于Qwen3.5-2B模型的商品自动标签标注系统，通过大模型蒸馏微调实现智能标签提取。提供FastAPI后端服务，支持RESTful API接口调用。

## 重要提示

✅ **解决方案**: 请安装CUDA版本的PyTorch以获得GPU加速（10-20倍性能提升）。

详见: [GPU_SETUP.md](GPU_SETUP.md)

快速安装命令:
```bash
python scripts/install_cuda_torch.py
```

## AI服务后端

### 快速启动

**Windows:**
```bash
start.bat
```

**Linux/macOS:**
```bash
chmod +x start.sh
./start.sh
```

### API接口

服务启动后，可以通过以下地址访问：

- **服务地址**: http://localhost:5001
- **API文档**: http://localhost:5001/docs
- **健康检查**: http://localhost:5001/health

### 主要接口

#### 1. 生成标签

```bash
POST /api/generate-tags
Content-Type: application/json

{
  "prompt": "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：天然维C片500mg\n商品描述：富含维生素 C，增强免疫力，抗氧化\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]"
}

Response:
{
  "tags": ["维生素", "增强免疫力", "抗氧化", "天然原料"]
}
```

#### 2. 健康检查

```bash
GET /health

Response:
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cuda:0"
}
```

### 测试服务

```bash
python test_api.py
```

详细文档请参考: [API_SERVICE.md](API_SERVICE.md)

## 项目结构

```
ai-service/
├── models/                    # 模型存储目录
│   ├── qwen3.5-2b/        # Qwen3.5-2B基座模型
│   ├── qwen3.5-2b-lora/    # LoRA微调后的模型
│   └── clip-vit-base/        # CLIP视觉模型（可选）
├── data/                     # 数据目录
│   ├── raw/                 # 原始数据
│   ├── processed/            # 处理后的数据
│   └── training/            # 训练数据
├── training/                 # 训练脚本
│   ├── prepare_data.py      # 数据准备
│   ├── distillation.py      # 蒸馏训练
│   ├── train_lora.py       # LoRA微调
│   └── evaluate.py         # 模型评估
├── inference/                # 推理脚本
│   ├── text_tagger.py      # 文本标签提取
│   ├── image_tagger.py     # 图像标签提取
│   └── batch_tagger.py    # 批量打标签
├── utils/                   # 工具函数
│   ├── model_loader.py     # 模型加载
│   ├── data_processor.py   # 数据处理
│   └── logger.py         # 日志工具
├── config/                  # 配置文件
│   ├── model_config.yaml   # 模型配置
│   └── training_config.yaml # 训练配置
├── scripts/                 # 脚本
│   ├── download_model.py   # 模型下载
│   └── setup_env.py      # 环境设置
├── tests/                   # 测试
│   └── test_tagger.py     # 测试脚本
├── requirements.txt          # Python依赖
├── README.md              # 项目说明
└── .gitignore            # Git忽略文件
```

## 快速开始

### 1. 环境设置

```bash
# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

### 2. 下载基座模型

```bash
python scripts/download_model.py
```

### 3. 准备训练数据

```bash
python training/prepare_data.py
```

### 4. 训练模型

```bash
python training/distillation.py
```

### 5. 推理测试

```bash
python inference/text_tagger.py
```

## 模型信息

- **基座模型**: Qwen/Qwen3.5-2B-Instruct
- **参数量**: 2.3B
- **用途**: 商品标签自动提取
- **微调方法**: LoRA (Low-Rank Adaptation)

## 技术栈

- PyTorch
- Transformers
- PEFT (LoRA)
- Hugging Face
- datasets

## 许可证

MIT License
