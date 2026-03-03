# 测试创建订单功能

## 测试步骤

### 1. 登录获取 Token
```powershell
$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"testuser1","password":"Test123456"}'
$token = $loginResponse.data.token
Write-Host "Token: $token"
```

### 2. 获取商品列表
```powershell
$headers = @{
    "Authorization" = "Bearer $token"
}
$products = Invoke-RestMethod -Uri "http://localhost:8080/v1/products" -Method GET -Headers $headers
Write-Host "商品列表: $($products.data | ConvertTo-Json -Depth 3)"
```

### 3. 获取用户地址
```powershell
$addresses = Invoke-RestMethod -Uri "http://localhost:8080/v1/addresses" -Method GET -Headers $headers
Write-Host "地址列表: $($addresses.data | ConvertTo-Json -Depth 3)"
```

### 4. 创建订单
```powershell
$createOrderBody = @{
    addressId = 1  # 使用第一个地址ID
    items = @(
        @{
            productId = 1  # 使用第一个商品ID
            quantity = 1
        }
    )
    remark = "测试订单"
} | ConvertTo-Json -Depth 3

Write-Host "创建订单请求: $createOrderBody"

try {
    $orderResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/orders" -Method POST -Headers $headers -Body $createOrderBody -ContentType "application/json"
    Write-Host "订单创建成功!"
    Write-Host "订单号: $($orderResponse.data.orderNo)"
    Write-Host "订单状态: $($orderResponse.data.status)"
    Write-Host "订单金额: $($orderResponse.data.totalAmount)"
    Write-Host "订单详情: $($orderResponse.data | ConvertTo-Json -Depth 5)"
} catch {
    Write-Host "创建订单失败: $_"
    Write-Host "错误详情: $($_.Exception.Message)"
    Write-Host "响应内容: $($_.ErrorDetails.Message)"
}
```

## 完整测试脚本

```powershell
# 创建订单测试脚本
Write-Host "========================================" -ForegroundColor Green
Write-Host "开始测试创建订单功能" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 1. 登录
Write-Host "`n[1] 登录获取 Token..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"testuser1","password":"Test123456"}'
    $token = $loginResponse.data.token
    Write-Host "✓ 登录成功" -ForegroundColor Green
    Write-Host "  Token: $token"
} catch {
    Write-Host "✗ 登录失败: $_" -ForegroundColor Red
    exit 1
}

# 设置请求头
$headers = @{
    "Authorization" = "Bearer $token"
}

# 2. 获取商品列表
Write-Host "`n[2] 获取商品列表..." -ForegroundColor Yellow
try {
    $products = Invoke-RestMethod -Uri "http://localhost:8080/v1/products" -Method GET -Headers $headers
    Write-Host "✓ 获取商品成功" -ForegroundColor Green
    Write-Host "  商品数量: $($products.data.Count)"
    if ($products.data.Count -gt 0) {
        Write-Host "  第一个商品: $($products.data[0].title) (ID: $($products.data[0].id), 价格: ¥$($products.data[0].price), 库存: $($products.data[0].stock))"
    }
} catch {
    Write-Host "✗ 获取商品失败: $_" -ForegroundColor Red
    exit 1
}

# 3. 获取地址列表
Write-Host "`n[3] 获取地址列表..." -ForegroundColor Yellow
try {
    $addresses = Invoke-RestMethod -Uri "http://localhost:8080/v1/addresses" -Method GET -Headers $headers
    Write-Host "✓ 获取地址成功" -ForegroundColor Green
    Write-Host "  地址数量: $($addresses.data.Count)"
    if ($addresses.data.Count -gt 0) {
        Write-Host "  第一个地址: $($addresses.data[0].receiverName) - $($addresses.data[0].fullAddress)"
    }
} catch {
    Write-Host "✗ 获取地址失败: $_" -ForegroundColor Red
    exit 1
}

# 4. 创建订单
Write-Host "`n[4] 创建订单..." -ForegroundColor Yellow
if ($products.data.Count -eq 0) {
    Write-Host "✗ 没有可用的商品" -ForegroundColor Red
    exit 1
}
if ($addresses.data.Count -eq 0) {
    Write-Host "✗ 没有可用的地址" -ForegroundColor Red
    exit 1
}

$createOrderBody = @{
    addressId = $addresses.data[0].id
    items = @(
        @{
            productId = $products.data[0].id
            quantity = 1
        }
    )
    remark = "测试订单 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} | ConvertTo-Json -Depth 3

Write-Host "  请求体: $createOrderBody"

try {
    $orderResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/orders" -Method POST -Headers $headers -Body $createOrderBody -ContentType "application/json"
    Write-Host "✓ 订单创建成功!" -ForegroundColor Green
    Write-Host "  订单号: $($orderResponse.data.orderNo)"
    Write-Host "  订单ID: $($orderResponse.data.id)"
    Write-Host "  订单状态: $($orderResponse.data.status)"
    Write-Host "  订单金额: ¥$($orderResponse.data.totalAmount)"
    Write-Host "  商品数量: $($orderResponse.data.itemCount)"
    Write-Host "  收货人: $($orderResponse.data.receiverName)"
    Write-Host "  收货电话: $($orderResponse.data.receiverPhone)"
    Write-Host "  收货地址: $($orderResponse.data.receiverAddress)"
    Write-Host "  支付过期时间: $($orderResponse.data.payExpireAt)"
    
    if ($orderResponse.data.items) {
        Write-Host "`n  订单商品:"
        foreach ($item in $orderResponse.data.items) {
            Write-Host "    - $($item.productTitle) x $($item.quantity) = ¥$($item.totalPrice)"
        }
    }
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "测试完成！所有步骤都成功了！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} catch {
    Write-Host "✗ 创建订单失败" -ForegroundColor Red
    Write-Host "  错误信息: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Host "  响应内容: $($_.ErrorDetails.Message)"
    }
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "测试失败！" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}
```

## 使用方法

将上述完整测试脚本保存为 `test-create-order.ps1`，然后运行：

```powershell
.\test-create-order.ps1
```

## 预期结果

如果一切正常，你应该看到：

```
========================================
开始测试创建订单功能
========================================

[1] 登录获取 Token...
✓ 登录成功
  Token: eyJhbGciOiJIUzI1NiJ9...

[2] 获取商品列表...
✓ 获取商品成功
  商品数量: X
  第一个商品: 商品名称 (ID: 1, 价格: ¥XX.XX, 库存: XX)

[3] 获取地址列表...
✓ 获取地址成功
  地址数量: X
  第一个地址: 收货人 - 详细地址

[4] 创建订单...
  请求体: {"addressId":1,"items":[{"productId":1,"quantity":1}],"remark":"测试订单..."}
✓ 订单创建成功!
  订单号: ORD20260303XXXXXX
  订单ID: XX
  订单状态: PENDING_CONFIRMATION
  订单金额: ¥XX.XX
  商品数量: 1
  收货人: XXX
  收货电话: XXX
  收货地址: XXX
  支付过期时间: XXX

  订单商品:
    - 商品名称 x 1 = ¥XX.XX

========================================
测试完成！所有步骤都成功了！
========================================
```

## 常见错误排查

### 错误1: "请先登录"
- 检查 Token 是否正确
- 检查 Token 是否过期

### 错误2: "商品不存在"
- 检查商品 ID 是否正确
- 检查商品是否存在

### 错误3: "商品已下架或缺货"
- 检查商品状态是否为 ON_SALE
- 检查商品库存是否充足

### 错误4: "收货地址不存在"
- 检查地址 ID 是否正确
- 检查地址是否存在

### 错误5: "库存不足"
- 检查商品库存是否充足
- 检查是否有多人同时购买

### 错误6: "Data truncated for column 'status'"
- 检查数据库 orders 表的 status 列 ENUM 定义是否包含所有状态
- 运行修复脚本: `database\fix_order_status_enum.sql`
