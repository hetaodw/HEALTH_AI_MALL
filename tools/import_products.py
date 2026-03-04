import mysql.connector
import json
import time

def import_products_from_json(json_file, db_config):
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    products = data['products']
    
    print("="*60)
    print("商品数据导入工具")
    print("="*60)
    print(f"\nJSON文件: {json_file}")
    print(f"商品总数: {len(products)}")
    
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        
        print("\n开始导入商品数据...")
        
        success_count = 0
        error_count = 0
        
        for i, product in enumerate(products, 1):
            try:
                sql = """INSERT INTO products 
                    (merchant_id, title, category, description, cover_url, features, 
                     description_content, price, stock, sales, average_rating, 
                     review_count, status, auto_confirm_mode)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
                
                values = (
                    product['merchant_id'],
                    product['title'],
                    product['category'],
                    product['description'],
                    product['cover_url'],
                    json.dumps(product['features'], ensure_ascii=False),
                    product['description_content'],
                    product['price'],
                    product['stock'],
                    product['sales'],
                    product['average_rating'],
                    product['review_count'],
                    product['status'],
                    product['auto_confirm_mode']
                )
                
                cursor.execute(sql, values)
                success_count += 1
                
                if i % 10 == 0:
                    print(f"  已导入: {i}/{len(products)}")
                    
            except Exception as e:
                error_count += 1
                print(f"  ✗ 第{i}条商品导入失败: {e}")
        
        conn.commit()
        
        print(f"\n{'='*60}")
        print(f"导入完成!")
        print(f"{'='*60}")
        print(f"  成功: {success_count}条")
        print(f"  失败: {error_count}条")
        
        cursor.execute("""
            SELECT 
                category as '商品分类',
                COUNT(*) as '商品数量',
                MIN(price) as '最低价格',
                MAX(price) as '最高价格',
                AVG(price) as '平均价格',
                SUM(sales) as '总销量'
            FROM products
            WHERE merchant_id = 4
            GROUP BY category
        """)
        
        print(f"\n分类统计:")
        print(f"{'-'*60}")
        print(f"{'分类':<20} {'数量':<10} {'最低价':<12} {'最高价':<12} {'平均价':<12} {'总销量':<10}")
        print(f"{'-'*60}")
        
        for row in cursor.fetchall():
            print(f"{row[0]:<20} {row[1]:<10} {row[2]:<12.2f} {row[3]:<12.2f} {row[4]:<12.2f} {row[5]:<10}")
        
        print(f"{'-'*60}")
        
        cursor.execute("SELECT COUNT(*) FROM products WHERE merchant_id = 4")
        total = cursor.fetchone()[0]
        print(f"总商品数: {total}")
        
        cursor.close()
        conn.close()
        
        return True
        
    except Exception as e:
        print(f"\n✗ 数据库连接错误: {e}")
        return False

def main():
    db_config = {
        'host': 'localhost',
        'port': 4000,
        'user': 'root',
        'password': 'root123456',
        'database': 'health_mall_system',
        'charset': 'utf8mb4'
    }
    
    json_file = 'd:\\26bs\\database\\generated_products.json'
    
    success = import_products_from_json(json_file, db_config)
    
    if success:
        print("\n" + "="*60)
        print("商品数据导入成功!")
        print("="*60)
        return 0
    else:
        print("\n" + "="*60)
        print("商品数据导入失败!")
        print("="*60)
        return 1

if __name__ == "__main__":
    import sys
    sys.exit(main())
