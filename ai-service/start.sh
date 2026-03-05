#!/bin/bash

echo "========================================"
echo "AI服务启动脚本"
echo "========================================"
echo ""

cd "$(dirname "$0")"

if [ ! -d "venv" ]; then
    echo "错误: 虚拟环境不存在，请先创建虚拟环境"
    echo "运行: python -m venv venv"
    exit 1
fi

source venv/bin/activate

if [ ! -d "logs" ]; then
    mkdir logs
fi

echo "检查模型文件..."
if [ ! -d "models/qwen2.5-3b-instruct" ]; then
    echo "警告: 模型文件不存在"
    echo "请先下载模型到 models/qwen2.5-3b-instruct 目录"
    exit 1
fi

echo "启动AI服务..."
echo "服务地址: http://localhost:5001"
echo "API文档: http://localhost:5001/docs"
echo ""

python app.py
