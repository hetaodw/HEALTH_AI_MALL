"""
快速GPU测试脚本
用于测试GPU加速效果
"""

import os

# 解决OpenMP冲突问题 - 必须在导入torch之前设置
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import torch
import time
from transformers import AutoTokenizer, AutoModelForCausalLM

def test_gpu():
    """
    测试GPU可用性和性能
    """
    print("=" * 60)
    print("GPU加速测试")
    print("=" * 60)
    
    # 检查CUDA
    cuda_available = torch.cuda.is_available()
    print(f"CUDA 可用: {cuda_available}")
    
    if cuda_available:
        print(f"CUDA 版本: {torch.version.cuda}")
        print(f"GPU 数量: {torch.cuda.device_count()}")
        print(f"GPU 名称: {torch.cuda.get_device_name(0)}")
        
        # GPU显存
        gpu_props = torch.cuda.get_device_properties(0)
        total_memory = gpu_props.total_memory / (1024 ** 3)
        print(f"GPU 显存: {total_memory:.2f} GB")
        
        # 当前显存使用
        allocated = torch.cuda.memory_allocated(0) / (1024 ** 3)
        cached = torch.cuda.memory_reserved(0) / (1024 ** 3)
        print(f"已分配显存: {allocated:.2f} GB")
        print(f"已缓存显存: {cached:.2f} GB")
    else:
        print("警告: CUDA 不可用，将使用CPU")
        print("建议运行: python scripts/install_cuda_torch.py")
    
    print("\n" + "=" * 60)
    print("PyTorch版本信息")
    print("=" * 60)
    print(f"PyTorch 版本: {torch.__version__}")
    print(f"是否为CUDA版本: {'cuda' in torch.__version__.lower()}")
    
    return cuda_available

def test_model_inference(model_path: str, use_gpu: bool = True):
    """
    测试模型推理速度
    
    Args:
        model_path: 模型路径
        use_gpu: 是否使用GPU
    """
    print("\n" + "=" * 60)
    print("模型推理测试")
    print("=" * 60)
    
    try:
        print(f"加载模型: {model_path}")
        
        # 加载tokenizer
        tokenizer = AutoTokenizer.from_pretrained(
            model_path,
            trust_remote_code=True
        )
        
        # 加载模型
        device = "cuda" if use_gpu and torch.cuda.is_available() else "cpu"
        print(f"使用设备: {device}")
        
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            torch_dtype=torch.float16 if device == "cuda" else torch.float32,
            device_map=device if device == "cuda" else None,
            trust_remote_code=True
        )
        
        model.eval()
        
        # 测试提示词
        test_prompt = "你好，请介绍一下自己。"
        
        print(f"\n测试提示词: {test_prompt}")
        
        # 预热
        print("预热...")
        inputs = tokenizer(test_prompt, return_tensors="pt").to(device)
        with torch.no_grad():
            _ = model.generate(**inputs, max_new_tokens=10)
        
        # 清理缓存
        if device == "cuda":
            torch.cuda.empty_cache()
        
        # 正式测试
        print("\n开始推理测试...")
        inputs = tokenizer(test_prompt, return_tensors="pt").to(device)
        
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
        if device == "cuda":
            allocated = torch.cuda.memory_allocated(0) / (1024 ** 3)
            print(f"\n显存使用: {allocated:.2f} GB")
        
        # 卸载模型
        del model
        del tokenizer
        if device == "cuda":
            torch.cuda.empty_cache()
        
        return inference_time
        
    except Exception as e:
        print(f"推理测试失败: {e}")
        return None

def main():
    """
    主函数
    """
    # 测试GPU
    cuda_available = test_gpu()
    
    if not cuda_available:
        print("\n" + "=" * 60)
        print("建议安装CUDA版本的PyTorch以获得更好的性能")
        print("=" * 60)
        print("\n运行以下命令安装CUDA版本:")
        print("  python scripts/install_cuda_torch.py")
        return
    
    # 测试模型推理
    model_path = "models/qwen2.5-3b-instruct"
    
    if not os.path.exists(model_path):
        print(f"\n警告: 模型不存在: {model_path}")
        print("请先运行: python scripts/download_model.py")
        return
    
    # 测试GPU推理
    print("\n" + "=" * 60)
    print("GPU推理测试")
    print("=" * 60)
    gpu_time = test_model_inference(model_path, use_gpu=True)
    
    # 测试CPU推理（对比）
    print("\n" + "=" * 60)
    print("CPU推理测试（对比）")
    print("=" * 60)
    cpu_time = test_model_inference(model_path, use_gpu=False)
    
    # 性能对比
    if gpu_time and cpu_time:
        print("\n" + "=" * 60)
        print("性能对比")
        print("=" * 60)
        print(f"GPU 推理时间: {gpu_time:.2f} 秒")
        print(f"CPU 推理时间: {cpu_time:.2f} 秒")
        print(f"GPU 加速比: {cpu_time / gpu_time:.2f}x")
        print(f"GPU 性能提升: {((cpu_time - gpu_time) / cpu_time * 100):.1f}%")

if __name__ == "__main__":
    main()
