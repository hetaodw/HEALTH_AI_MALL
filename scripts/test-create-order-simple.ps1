Write-Host "========================================" -ForegroundColor Green
Write-Host "开始测试创建订单功能" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$headers = @{}

# 1. 登录
Write-Host "`n[1] 登录获取 Token..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"testuser1","password":"Test123456"}'
    $token = $loginResponse.data.token
    Write-Host "✓ 登录成功" -ForegroundColor Green
    Write-Host "  Token: $token"
    $headers = @{
        "Authorization" = "Bearer $token"
    }
} catch {
    Write-Host "✗ 登录失败: $_" -ForegroundColor Red
    exit 1
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
    remark = "Test Order - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
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
