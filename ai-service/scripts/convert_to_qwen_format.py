import json
import os

input_path = "d:\\26bs\\ai-service\\data\\training\\training_data.json"
output_path = "d:\\26bs\\ai-service\\data\\training\\training_data_qwen.jsonl"

def convert_to_qwen_format(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    converted_data = []
    
    for item in data:
        title = item.get('商品标题', '')
        description = item.get('商品介绍', '')
        tags = item.get('tag', '')
        
        instruction = f"请为以下商品生成标签：\n商品标题：{title}\n商品介绍：{description}"
        output = tags
        
        converted_data.append({
            "instruction": instruction,
            "output": output
        })
    
    with open(output_file, 'w', encoding='utf-8') as f:
        for item in converted_data:
            f.write(json.dumps(item, ensure_ascii=False) + '\n')
    
    print(f"转换完成！共处理 {len(converted_data)} 条数据")
    print(f"输出文件: {output_file}")
    
    return converted_data

if __name__ == "__main__":
    convert_to_qwen_format(input_path, output_path)
