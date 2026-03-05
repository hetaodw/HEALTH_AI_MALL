import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel

base_model_path = r'D:\26bs\ai-service\models\Qwen3___5-2B'
lora_adapter_path = r'D:\26bs\ai-service\models\qwen3.5-2b-lora-finetuned'

print("Loading tokenizer...")
tokenizer = AutoTokenizer.from_pretrained(base_model_path, trust_remote_code=True)

print("Loading base model...")
base_model = AutoModelForCausalLM.from_pretrained(
    base_model_path,
    torch_dtype=torch.float16,
    device_map="auto",
    trust_remote_code=True
)

print("Loading LoRA adapter...")
model = PeftModel.from_pretrained(base_model, lora_adapter_path, torch_dtype=torch.float16)
model.eval()

device = next(model.parameters()).device
print(f"Model loaded on: {device}")

prompt = """<|im_start|>user
请为以下商品生成标签：
商品标题：无线蓝牙耳机 Pro
商品介绍：主动降噪，长续航30小时，Hi-Fi音质，兼容苹果安卓
<|im_end|>
<|im_start|>assistant
"""

print("\n=== Prompt ===")
print(prompt)

inputs = tokenizer(prompt, return_tensors="pt").to(device)

with torch.no_grad():
    outputs = model.generate(
        **inputs,
        max_new_tokens=512,
        temperature=0.7,
        do_sample=True,
        top_p=0.9,
        top_k=50,
        repetition_penalty=1.1
    )

response = tokenizer.decode(outputs[0], skip_special_tokens=False)
print("\n=== Raw Output ===")
print(response)

print("\n=== Parsed Output ===")
print(response[len(prompt):])
