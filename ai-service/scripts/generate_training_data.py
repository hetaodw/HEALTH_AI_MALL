import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'

import json
from openai import OpenAI

client = OpenAI(
    api_key="sk-rmlFsgQlM1HyhtKLUdZ9GOtfTti9iAyDHlw18vPEJmStz8vR",
    base_url="https://xiaohuapi.site/v1"
)

prompt_path = "d:\\26bs\\ai-service\\scripts\\promot.md"

with open(prompt_path, "r", encoding="utf-8") as f:
    prompt = f.read()

output_path = "d:\\26bs\\ai-service\\data\\training\\training_data.json"
os.makedirs(os.path.dirname(output_path), exist_ok=True)

def parse_content(content):
    lines = content.strip().split('\n')
    data = []
    current_item = {}
    
    for line in lines:
        line = line.strip()
        if line.startswith('商品标题：'):
            current_item = {}
            current_item['商品标题'] = line.replace('商品标题：', '').strip()
        elif line.startswith('商品介绍：'):
            current_item['商品介绍'] = line.replace('商品介绍：', '').strip()
        elif line.startswith('tag：'):
            current_item['tag'] = line.replace('tag：', '').strip()
            data.append(current_item)
    
    return data

def save_to_json(new_data):
    existing_data = []
    if os.path.exists(output_path):
        with open(output_path, "r", encoding="utf-8") as f:
            existing_data = json.load(f)
    
    existing_data.extend(new_data)
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(existing_data, f, ensure_ascii=False, indent=2)

for group in range(1, 300):
    print(f"正在生成第 {group} 组数据...")
    
    response = client.chat.completions.create(
        model="claude-sonnet-4-5",
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": "请生成 20 条训练数据："}
        ],
        temperature=0.7,
        max_tokens=2000
    )
    
    content = response.choices[0].message.content
    data = parse_content(content)
    
    save_to_json(data)
    
    print(f"第 {group} 组成功生成 {len(data)} 条训练数据")
    print(f"当前总数据量: {len(data) * group} 条")

print(f"所有数据已保存到: {output_path}")

