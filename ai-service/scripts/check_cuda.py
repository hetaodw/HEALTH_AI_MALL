"""
检查CUDA和GPU可用性
"""

import os

# 解决OpenMP冲突问题 - 必须在导入torch之前设置
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
import sys

print("=" * 60)
print("CUDA/GPU 检查")
print("=" * 60)

# 检查CUDA可用性
cuda_available = torch.cuda.is_available()
print(f"CUDA 可用: {cuda_available}")

if cuda_available:
    # CUDA版本
    print(f"CUDA 版本: {torch.version.cuda}")
    
    # GPU数量
    gpu_count = torch.cuda.device_count()
    print(f"GPU 数量: {gpu_count}")
    
    # GPU名称
    if gpu_count > 0:
        print(f"GPU 名称: {torch.cuda.get_device_name(0)}")
        
        # GPU显存
        gpu_props = torch.cuda.get_device_properties(0)
        total_memory = gpu_props.total_memory / (1024 ** 3)
        print(f"GPU 显存: {total_memory:.2f} GB")
        
        # 当前设备
        current_device = torch.cuda.current_device()
        print(f"当前设备: cuda:{current_device}")
    else:
        print("警告: 没有检测到GPU")
else:
    print("警告: CUDA 不可用，将使用CPU")
    print("请检查:")
    print("1. 是否安装了CUDA版本的PyTorch")
    print("2. 是否安装了NVIDIA GPU驱动")
    print("3. 是否安装了CUDA Toolkit")

# PyTorch版本
print(f"PyTorch 版本: {torch.__version__}")

# 设备推荐
print("\n" + "=" * 60)
print("设备推荐")
print("=" * 60)

if cuda_available:
    print("✓ 推荐使用 CUDA (GPU) 进行推理和训练")
    print("  优势: 速度快，适合大规模模型")
    print("  使用方法: device='cuda' 或 device_map='auto'")
else:
    print("✗ CUDA 不可用，将使用 CPU")
    print("  限制: 速度慢，不适合大模型")
    print("  建议: 安装CUDA版本的PyTorch或使用量化模型")

print("=" * 60)
