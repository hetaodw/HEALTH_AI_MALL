"""
安装CUDA版本的PyTorch
解决CPU版本导致的推理慢问题
"""

import subprocess
import sys
import os

def uninstall_cpu_torch():
    """
    卸载CPU版本的PyTorch
    """
    print("=" * 60)
    print("卸载CPU版本的PyTorch")
    print("=" * 60)

    packages_to_remove = [
        "torch",
        "torchvision",
        "torchaudio"
    ]

    for package in packages_to_remove:
        try:
            result = subprocess.run(
                [sys.executable, "-m", "pip", "uninstall", "-y", package],
                capture_output=True,
                text=True
            )
            print(f"卸载 {package}: {'成功' if result.returncode == 0 else '失败'}")
        except Exception as e:
            print(f"卸载 {package} 时出错: {e}")

    print("CPU版本PyTorch卸载完成\n")

def install_cuda_torch():
    """
    安装CUDA版本的PyTorch
    """
    print("=" * 60)
    print("安装CUDA版本的PyTorch")
    print("=" * 60)

    # CUDA 12.1版本的PyTorch
    install_commands = [
        "pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121"
    ]

    for cmd in install_commands:
        try:
            print(f"执行命令: {cmd}")
            result = subprocess.run(
                cmd,
                shell=True,
                check=True,
                capture_output=True,
                text=True
            )
            print("安装成功")
        except subprocess.CalledProcessError as e:
            print(f"安装失败: {e}")
            print(f"错误输出: {e.stderr}")
            return False

    print("CUDA版本PyTorch安装完成\n")
    return True

def verify_installation():
    """
    验证安装
    """
    print("=" * 60)
    print("验证安装")
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
            print("\n✓ CUDA版本PyTorch安装成功！")
        else:
            print("\n✗ CUDA仍然不可用")
            print("可能原因:")
            print("1. 系统没有NVIDIA GPU")
            print("2. 没有安装NVIDIA GPU驱动")
            print("3. CUDA版本与GPU不兼容")
            return False

    except Exception as e:
        print(f"验证失败: {e}")
        return False

    return True

if __name__ == "__main__":
    print("=" * 60)
    print("PyTorch CPU版本 -> CUDA版本 升级工具")
    print("=" * 60)
    print()

    # 询问用户确认
    confirm = input("这将卸载当前的CPU版本PyTorch并安装CUDA版本，确认继续? (y/n): ")
    if confirm.lower() != 'y':
        print("操作已取消")
        sys.exit(0)

    # 卸载CPU版本
    uninstall_cpu_torch()

    # 安装CUDA版本
    if install_cuda_torch():
        # 验证安装
        if verify_installation():
            print("\n" + "=" * 60)
            print("升级完成！现在可以使用GPU加速了")
            print("=" * 60)
        else:
            print("\n" + "=" * 60)
            print("安装完成但CUDA不可用，请检查GPU驱动")
            print("=" * 60)
    else:
        print("\n安装失败，请检查错误信息")
