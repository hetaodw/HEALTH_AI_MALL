"""
从魔搭社区下载Qwen3.5-2B模型
"""

import os

# 解决OpenMP冲突问题
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

# 设置modelscope缓存目录为当前目录
os.environ['MODELSCOPE_CACHE'] = os.path.join(os.getcwd(), '.modelscope_cache')

from modelscope import snapshot_download

print("=" * 60)
print("从魔搭社区下载Qwen3.5-2B模型")
print("=" * 60)

model_id = "Qwen/Qwen3.5-2B"
local_dir = "models/qwen3.5-2b"

print(f"模型ID: {model_id}")
print(f"本地路径: {local_dir}")
print(f"缓存目录: {os.environ['MODELSCOPE_CACHE']}")

try:
    print("\n开始下载...")
    snapshot_download(
        model_id,
        cache_dir='.modelscope_cache',
        local_dir=local_dir,
        revision='master'
    )
    
    print("\n✓ 模型下载完成")
    print(f"模型路径: {os.path.abspath(local_dir)}")
    
except Exception as e:
    print(f"\n✗ 下载失败: {e}")
    raise

print("=" * 60)
