"""
重新下载Qwen2.5-3B模型
"""

import os

# 解决OpenMP冲突问题
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

from huggingface_hub import snapshot_download

print("=" * 60)
print("下载Qwen2.5-3B-Instruct模型")
print("=" * 60)

repo_id = "Qwen/Qwen2.5-3B-Instruct"
local_dir = "models/qwen2.5-3b-instruct"

print(f"仓库: {repo_id}")
print(f"本地路径: {local_dir}")

try:
    print("\n开始下载...")
    snapshot_download(
        repo_id=repo_id,
        local_dir=local_dir,
        local_dir_use_symlinks=False
    )
    
    print("\n✓ 模型下载完成")
    print(f"模型路径: {os.path.abspath(local_dir)}")
    
except Exception as e:
    print(f"\n✗ 下载失败: {e}")
    raise

print("=" * 60)
