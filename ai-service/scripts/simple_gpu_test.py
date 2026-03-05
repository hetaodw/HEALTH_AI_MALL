"""
简单GPU推理测试
"""

import os

os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

print("CUDA 可用:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
    print("显存:", torch.cuda.get_device_properties(0).total_memory / 1024**3, "GB")

model_path = "models/Qwen3___5-2B"
print("\n加载模型...")

tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    torch_dtype=torch.float16,
    device_map="cuda",
    trust_remote_code=True
)
model.eval()

print("\n模型加载完成！")

test_prompt = "你好"
print("\n测试提示词:", test_prompt)

inputs = tokenizer(test_prompt, return_tensors="pt").to("cuda")

with torch.no_grad():
    outputs = model.generate(**inputs, max_new_tokens=20)

response = tokenizer.decode(outputs[0], skip_special_tokens=True)

print("\n模型输出:")
print(response)

print("\n显存使用:", torch.cuda.memory_allocated(0) / (1024 ** 3), "GB")
print("\nGPU推理测试完成！")
