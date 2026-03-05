@echo off
chcp 65001 >nul
echo ========================================
echo AI服务启动脚本
echo ========================================
echo.

cd /d "%~dp0"

if not exist "venv\Scripts\activate.bat" (
    echo 错误: 虚拟环境不存在，请先创建虚拟环境
    echo 运行: python -m venv venv
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

if not exist "logs" (
    mkdir logs
)

echo 检查模型文件...
if not exist "models\qwen2.5-3b-instruct" (
    echo 警告: 模型文件不存在
    echo 请先下载模型到 models\qwen2.5-3b-instruct 目录
    pause
    exit /b 1
)

echo 启动AI服务...
echo 服务地址: http://localhost:5001
echo API文档: http://localhost:5001/docs
echo.

python app.py

pause
