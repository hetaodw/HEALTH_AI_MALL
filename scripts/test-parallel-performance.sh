#!/bin/bash

BASE_URL="http://localhost:8080/v1"

echo "=== 并行处理性能测试 ==="
echo ""

# 登录
echo "登录中..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"testmerchant1","password":"Test123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "登录失败"
  exit 1
fi

echo "登录成功"
echo ""

# 测试批量生成标签
echo "测试批量生成标签（5个商品）..."
START_TIME=$(date +%s%3N)

RESPONSE=$(curl -s -X POST "$BASE_URL/products/tags/batch/generate" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productIds":[1,2,3,4,5]}')

END_TIME=$(date +%s%3N)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "测试结果:"
echo "  响应时间: ${DURATION}ms"
echo "  响应内容: $RESPONSE"
echo ""

if [ $DURATION -lt 2000 ]; then
  echo "✅ 性能优化成功！响应时间从 17秒 降至 ${DURATION}ms"
elif [ $DURATION -lt 5000 ]; then
  echo "⚠️ 性能有所改善，但仍有优化空间。响应时间: ${DURATION}ms"
else
  echo "❌ 性能优化效果不佳。响应时间: ${DURATION}ms"
fi

echo ""
echo "=== 测试完成 ==="
