import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

print("CUDA:", torch.cuda.is_available())
print("GPU:", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "N/A")

model_path = "models/Qwen3___5-2B"
print("Loading model...")

tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    torch_dtype=torch.float16,
    device_map="cuda",
    trust_remote_code=True
)
model.eval()

print("Model loaded!")
print("VRAM:", round(torch.cuda.memory_allocated(0) / (1024 ** 3), 2), "GB")

test_prompt = "Hello"
inputs = tokenizer(test_prompt, return_tensors="pt").to("cuda")

with torch.no_grad():
    outputs = model.generate(**inputs, max_new_tokens=5)

response = tokenizer.decode(outputs[0], skip_special_tokens=True)
print("Response:", response)
print("GPU inference test completed!")
