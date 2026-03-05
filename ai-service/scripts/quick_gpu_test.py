"""
快速GPU推理测试
"""

import os

# 解决OpenMP冲突问题
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
import time
from transformers import AutoTokenizer, AutoModelForCausalLM

print("=" * 60)
print("GPU推理测试")
print("=" * 60)

# 检查CUDA
print(f"CUDA 可用: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"显存: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB")

# 加载模型 - 使用绝对路径
script_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(script_dir, "..", "models", "Qwen3___5-2B")
model_path = os.path.abspath(model_path)
print(f"\n加载模型: {model_path}")

print("加载tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True, local_files_only=True)

print("加载模型...")
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    torch_dtype=torch.float16,
    device_map="cuda",
    trust_remote_code=True,
    local_files_only=True
)
model.eval()

# 测试推理
test_prompt = "你好，请介绍一下自己。"
print(f"\n测试提示词: {test_prompt}")

# 预热
print("预热...")
inputs = tokenizer(test_prompt, return_tensors="pt").to("cuda")
with torch.no_grad():
    _ = model.generate(**inputs, max_new_tokens=10)

# 清理缓存
torch.cuda.empty_cache()

# 正式测试
print("\n开始推理测试...")
inputs = tokenizer(test_prompt, return_tensors="pt").to("cuda")

start_time = time.time()
with torch.no_grad():
    outputs = model.generate(
        **inputs,
        max_new_tokens=50,
        temperature=0.7,
        do_sample=True,
        top_p=0.9,
        repetition_penalty=1.1
    )
end_time = time.time()

# 计算时间
inference_time = end_time - start_time

# 解码输出
response = tokenizer.decode(outputs[0], skip_special_tokens=True)

# 打印结果
print(f"\n推理时间: {inference_time:.2f} 秒")
print(f"生成token数: 50")
print(f"速度: {50 / inference_time:.2f} tokens/秒")

print(f"\n模型输出:")
print("-" * 60)
print(response)
print("-" * 60)

# 显存使用
allocated = torch.cuda.memory_allocated(0) / (1024 ** 3)
print(f"\n显存使用: {allocated:.2f} GB")

print("\n" + "=" * 60)
print("GPU加速测试完成！")
print("=" * 60)
