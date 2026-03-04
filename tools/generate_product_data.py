import json
import time
from openai import OpenAI

class ProductDataGenerator:
    def __init__(self, api_key=None):
        self.api_key = api_key or "sk-806cf01ff3c94b8fbee193e64b4602fa"
        self.client = OpenAI(
            api_key=self.api_key,
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        )
    
    def generate_batch_products(self, batch_num, total_batches, category, count, merchant_id=4):
        prompt = f"""请生成{count}条{category}分类的商品数据，用于推荐队列开发测试。要求：

商品分类：{category}
生成数量：{count}条
批次：{batch_num}/{total_batches}

请按照以下JSON格式输出商品数据：
[
  {{
    "title": "商品标题（10-30字）",
    "description": "商品简短描述（10-20字）",
    "description_content": "商品详细文字介绍内容（50-100字）",
    "features": {{"brand": "品牌名称", "specification": "规格说明", "origin": "产地"}},
    "price": 价格（数字，保留2位小数），
    "stock": 库存数量（20-500之间的整数），
    "sales": 销量（50-2000之间的整数），
    "average_rating": 平均评分（3.5-5.0之间的数字，保留1位小数），
    "review_count": 评价数量（10-200之间的整数），
    "status": "ON_SALE"
  }}
]

商品数据要求：
1. title: 商品标题要简洁明了，突出产品特点
2. description: 简短描述，概括产品主要功能
3. description_content: 详细介绍产品功效、适用人群、使用方法等
4. features: 包含品牌、规格、产地等信息，使用JSON格式
5. price: 价格范围根据产品类型合理设置（20-5000元）
6. stock: 库存数量合理设置
7. sales: 销量数据要真实可信
8. average_rating: 评分与评价数量要匹配
9. review_count: 评价数量要合理
10. status: 统一为"ON_SALE"

商品分类说明：
- HEALTH_PRODUCTS: 保健品（维生素、矿物质、草本提取物等）
- MEDICAL_DEVICES: 医疗器械（血压计、血糖仪、按摩设备等）
- HEALTH_FOOD: 健康食品（有机食品、坚果、蜂蜜、茶饮等）
- SPORTS_FITNESS: 运动健身（瑜伽垫、哑铃、健身器材等）
- MATERNAL_BABY: 母婴用品（孕妇用品、婴儿用品等）

注意事项：
1. 商品标题要包含产品类型和主要特点
2. 价格要符合市场行情
3. 销量和评分要匹配
4. 详细介绍要专业且易懂
5. 品牌名称要真实可信
6. 产地要合理
7. 每个商品都要有独特性，避免重复

请只输出JSON数组，不要包含其他说明文字。"""

        messages = [{"role": "user", "content": prompt}]
        
        max_retries = 3
        for attempt in range(max_retries):
            try:
                completion = self.client.chat.completions.create(
                    model="qwen3.5-plus",
                    messages=messages,
                    extra_body={"enable_thinking": True},
                    stream=False
                )
                
                response_text = completion.choices[0].message.content
                
                result = self._parse_json_response(response_text)
                if result and isinstance(result, list):
                    return result
                    
            except Exception as e:
                print(f"    生成批次 {batch_num} 时出错 (尝试 {attempt + 1}/{max_retries}): {e}")
                if attempt < max_retries - 1:
                    time.sleep(2)
                    continue
                else:
                    return None
        
        return None
    
    def _parse_json_response(self, response_text):
        json_start = response_text.find('[')
        json_end = response_text.rfind(']') + 1
        
        if json_start == -1 or json_end <= json_start:
            raise ValueError("未找到有效的JSON数组格式")
        
        json_text = response_text[json_start:json_end]
        
        try:
            result = json.loads(json_text)
            return result
        except json.JSONDecodeError as e:
            print(f"    JSON解析错误: {e}")
            print(f"    尝试修复JSON格式...")
            
            try:
                fixed_json = self._fix_json(json_text)
                result = json.loads(fixed_json)
                print("    JSON修复成功")
                return result
            except Exception as fix_error:
                print(f"    JSON修复失败: {fix_error}")
                raise
    
    def _fix_json(self, json_text):
        import re
        
        fixed_json = json_text
        
        fixed_json = re.sub(r',\s*}', '}', fixed_json)
        fixed_json = re.sub(r',\s*]', ']', fixed_json)
        fixed_json = re.sub(r'\\n', ' ', fixed_json)
        fixed_json = re.sub(r'\\r', ' ', fixed_json)
        fixed_json = re.sub(r'\\t', ' ', fixed_json)
        
        return fixed_json
    
    def generate_all_products(self, output_file):
        categories = [
            ("HEALTH_PRODUCTS", 50, 5),
            ("MEDICAL_DEVICES", 40, 4),
            ("HEALTH_FOOD", 40, 4),
            ("SPORTS_FITNESS", 40, 4),
            ("MATERNAL_BABY", 40, 4)
        ]
        
        print("="*60)
        print("商品数据生成工具")
        print("="*60)
        print(f"\n输出文件: {output_file}")
        
        all_products = []
        total_batches = sum(batches for _, _, batches in categories)
        current_batch = 0
        
        for category, total_count, batches in categories:
            count_per_batch = total_count // batches
            remaining = total_count % batches
            
            print(f"\n{'='*60}")
            print(f"分类: {category}")
            print(f"总数量: {total_count}条")
            print(f"批次数: {batches}")
            print(f"{'='*60}")
            
            for batch_num in range(1, batches + 1):
                current_batch += 1
                batch_count = count_per_batch + (1 if batch_num <= remaining else 0)
                
                print(f"\n[{current_batch}/{total_batches}] 批次 {batch_num}/{batches} - 生成 {batch_count} 条商品...")
                
                products = self.generate_batch_products(
                    batch_num, batches, category, batch_count
                )
                
                if products:
                    for product in products:
                        product['merchant_id'] = 4
                        product['category'] = category
                        product['cover_url'] = f"http://localhost:8080/v1/static/product/cover/{category.lower()}_{batch_num}_{len(all_products) % 10 + 1}.jpg"
                        product['auto_confirm_mode'] = 'MANUAL'
                        all_products.append(product)
                    
                    print(f"    ✓ 批次 {batch_num} 完成，生成 {len(products)} 条商品")
                else:
                    print(f"    ✗ 批次 {batch_num} 失败")
                
                time.sleep(1)
        
        if all_products:
            result = {
                "total_products": len(all_products),
                "categories_summary": {
                    cat: sum(1 for p in all_products if p['category'] == cat)
                    for cat, _, _ in categories
                },
                "products": all_products
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(result, f, ensure_ascii=False, indent=2)
            
            print(f"\n{'='*60}")
            print(f"✓ 所有商品数据已保存到: {output_file}")
            print(f"  总商品数: {len(all_products)}")
            print(f"\n分类统计:")
            for category, _, _ in categories:
                count = sum(1 for p in all_products if p['category'] == category)
                print(f"  - {category}: {count}条")
            print(f"{'='*60}")
            return True
        else:
            print(f"\n{'='*60}")
            print(f"✗ 未能生成任何商品数据")
            print(f"{'='*60}")
            return False

def generate_sql_from_json(json_file, sql_file):
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    products = data['products']
    
    sql_statements = [
        "-- 批量插入商品数据用于推荐队列开发测试",
        "-- 包含{}条商品数据，涵盖不同分类、价格、销量等".format(len(products)),
        "",
        "USE health_mall_system;",
        "",
        "-- 禁用外键检查",
        "SET FOREIGN_KEY_CHECKS = 0;",
        ""
    ]
    
    for product in products:
        sql = """INSERT INTO products (merchant_id, title, category, description, cover_url, features, description_content, price, stock, sales, average_rating, review_count, status, auto_confirm_mode, created_at, updated_at)
VALUES ({merchant_id}, '{title}', '{category}', '{description}', '{cover_url}', '{features}', '{description_content}', {price}, {stock}, {sales}, {average_rating}, {review_count}, '{status}', '{auto_confirm_mode}', NOW(), NOW());""".format(
            merchant_id=product['merchant_id'],
            title=product['title'].replace("'", "\\'"),
            category=product['category'],
            description=product['description'].replace("'", "\\'"),
            cover_url=product['cover_url'],
            features=json.dumps(product['features'], ensure_ascii=False).replace("'", "\\'"),
            description_content=product['description_content'].replace("'", "\\'"),
            price=product['price'],
            stock=product['stock'],
            sales=product['sales'],
            average_rating=product['average_rating'],
            review_count=product['review_count'],
            status=product['status'],
            auto_confirm_mode=product['auto_confirm_mode']
        )
        sql_statements.append(sql)
    
    sql_statements.extend([
        "",
        "-- 重新启用外键检查",
        "SET FOREIGN_KEY_CHECKS = 1;",
        "",
        "-- 显示统计信息",
        "SELECT ",
        "  category as '商品分类',",
        "  COUNT(*) as '商品数量',",
        "  MIN(price) as '最低价格',",
        "  MAX(price) as '最高价格',",
        "  AVG(price) as '平均价格',",
        "  SUM(sales) as '总销量'",
        "FROM products",
        "WHERE merchant_id = 4",
        "GROUP BY category;",
        "",
        "SELECT '数据插入完成！' as '状态', COUNT(*) as '总商品数' FROM products WHERE merchant_id = 4;"
    ])
    
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_statements))
    
    print(f"\n✓ SQL脚本已保存到: {sql_file}")
    return True

def main():
    generator = ProductDataGenerator()
    
    json_output_file = "d:\\26bs\\database\\generated_products.json"
    sql_output_file = "d:\\26bs\\database\\insert_generated_products.sql"
    
    success = generator.generate_all_products(json_output_file)
    
    if success:
        print("\n开始生成SQL脚本...")
        generate_sql_from_json(json_output_file, sql_output_file)
        print("\n" + "="*60)
        print("商品数据生成完成!")
        print("="*60)
        print(f"\n生成的文件:")
        print(f"  1. JSON数据: {json_output_file}")
        print(f"  2. SQL脚本: {sql_output_file}")
        print(f"\n使用方法:")
        print(f"  1. 查看JSON数据了解商品详情")
        print(f"  2. 执行SQL脚本导入数据库:")
        print(f"     mysql -h localhost -P 4000 -u root -p < {sql_output_file}")
        return 0
    else:
        print("\n" + "="*60)
        print("商品数据生成失败!")
        print("="*60)
        return 1

if __name__ == "__main__":
    import sys
    sys.exit(main())
