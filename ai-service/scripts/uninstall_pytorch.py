"""
卸载PyTorch脚本
仅卸载PyTorch相关包，方便手动安装适合设备的版本
"""

import subprocess
import sys

def uninstall_pytorch():
    """
    卸载PyTorch相关包
    """
    print("=" * 60)
    print("卸载PyTorch")
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
            if result.returncode == 0:
                print(f"✓ {package}: 卸载成功")
            else:
                print(f"- {package}: 未安装或卸载失败")
        except Exception as e:
            print(f"✗ {package}: 卸载出错 - {e}")

    print("\n" + "=" * 60)
    print("PyTorch卸载完成")
    print("=" * 60)
    print("\n现在可以手动安装适合您设备的PyTorch版本")
    print("\n推荐安装命令:")
    print("  CUDA 12.1: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121")
    print("  CUDA 12.4: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124")
    print("  CUDA 11.8: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
    print("  CPU版本:   pip install torch torchvision torchaudio")

if __name__ == "__main__":
    import os
    
    # 解决OpenMP冲突问题
    os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'
    
    # 询问确认
    confirm = input("确认卸载PyTorch? (y/n): ")
    if confirm.lower() == 'y':
        uninstall_pytorch()
    else:
        print("操作已取消")
