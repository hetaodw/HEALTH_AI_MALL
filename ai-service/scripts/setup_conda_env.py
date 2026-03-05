"""
Anaconda环境设置脚本
创建并配置AI服务的conda环境
"""

import subprocess
import sys
import os

def create_conda_env():
    """
    创建conda环境
    """
    print("=" * 60)
    print("创建Anaconda环境")
    print("=" * 60)
    
    env_name = "ai-service"
    env_file = "environment.yml"
    
    if not os.path.exists(env_file):
        print(f"错误: 环境配置文件不存在: {env_file}")
        return False
    
    try:
        # 创建环境
        print(f"创建环境: {env_name}")
        result = subprocess.run(
            ["conda", "env", "create", "-f", env_file],
            check=True,
            capture_output=True,
            text=True
        )
        
        print("✓ 环境创建成功")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"✗ 环境创建失败: {e}")
        print(f"错误输出: {e.stderr}")
        return False

def activate_env_instructions():
    """
    显示环境激活说明
    """
    print("\n" + "=" * 60)
    print("环境激活说明")
    print("=" * 60)
    print("\nWindows PowerShell:")
    print("  conda activate ai-service")
    print("\nWindows CMD:")
    print("  conda activate ai-service")
    print("\nLinux/Mac:")
    print("  source activate ai-service")
    print("\n" + "=" * 60)

def verify_cuda():
    """
    验证CUDA安装
    """
    print("\n" + "=" * 60)
    print("验证CUDA安装")
    print("=" * 60)
    
    try:
        import torch
        print(f"PyTorch 版本: {torch.__version__}")
        print(f"CUDA 可用: {torch.cuda.is_available()}")
        
        if torch.cuda.is_available():
            print(f"CUDA 版本: {torch.version.cuda}")
            print(f"GPU 数量: {torch.cuda.device_count()}")
            if torch.cuda.device_count() > 0:
                print(f"GPU 名称: {torch.cuda.get_device_name(0)}")
            print("\n✓ CUDA配置成功")
        else:
            print("\n✗ CUDA不可用")
            print("请检查:")
            print("1. 是否安装了NVIDIA GPU驱动")
            print("2. CUDA版本是否与GPU兼容")
            
    except ImportError:
        print("✗ PyTorch未安装")
        print("请先激活环境: conda activate ai-service")

def main():
    """
    主函数
    """
    print("=" * 60)
    print("AI服务 - Anaconda环境配置")
    print("=" * 60)
    
    # 询问用户
    print("\n此脚本将:")
    print("1. 创建名为 'ai-service' 的conda环境")
    print("2. 安装CUDA 12.1版本的PyTorch")
    print("3. 安装所有依赖包")
    print("\n预计需要时间: 5-10分钟")
    
    confirm = input("\n确认创建环境? (y/n): ")
    if confirm.lower() != 'y':
        print("操作已取消")
        return
    
    # 创建环境
    if create_conda_env():
        activate_env_instructions()
        
        print("\n" + "=" * 60)
        print("下一步")
        print("=" * 60)
        print("\n1. 激活环境:")
        print("   conda activate ai-service")
        print("\n2. 验证CUDA:")
        print("   python scripts/check_cuda.py")
        print("\n3. 测试GPU:")
        print("   python scripts/test_gpu.py")

if __name__ == "__main__":
    main()
