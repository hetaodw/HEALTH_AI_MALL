# 为所有没有标签的商品生成标签

$token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0bWVyY2hhbnQxIiwiaWF0IjoxNzcyNjcyNTk4LCJleHAiOjE3NzI3NTg5OTh9.9vQ3JWvGzXgYpKqZLhJ8fM4Q5hN7Rk2sT3mV6xP8yY"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# 获取所有商品ID
Write-Host "获取所有商品列表..."
$allProducts = Invoke-RestMethod -Uri "http://localhost:8080/v1/products?page=1&size=100" -Method Get

# 找出没有标签的商品
$productsWithoutTags = @()
foreach ($product in $allProducts.data.list) {
    $tags = Invoke-RestMethod -Uri "http://localhost:8080/v1/products/tags/$($product.id)" -Method Get
    if ($null -eq $tags.data -or $tags.data.Count -eq 0) {
        $productsWithoutTags += $product
    }
}

Write-Host "找到 $($productsWithoutTags.Count) 个没有标签的商品"
Write-Host ""

# 为每个没有标签的商品生成标签
$successCount = 0
$failedCount = 0
$failedProductIds = @()

foreach ($product in $productsWithoutTags) {
    Write-Host "正在为商品 ID=$($product.id) 生成标签..."
    Write-Host "  标题: $($product.title)"
    Write-Host "  描述: $($product.description)"

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/products/tags/$($product.id)/generate" -Method Post -Headers $headers -TimeoutSec 60
        $generatedTags = $response.data -join ', '

        if ($generatedTags) {
            Write-Host "  ✓ 生成成功: $generatedTags"
            $successCount++
        } else {
            Write-Host "  ⚠ 生成成功但标签为空"
            $successCount++
        }
    } catch {
        Write-Host "  ✗ 生成失败: $($_.Exception.Message)"
        $failedCount++
        $failedProductIds += $product.id
    }

    Write-Host ""
    Start-Sleep -Seconds 2  # 避免请求过快
}

# 输出总结
Write-Host "========================================"
Write-Host "标签生成完成！"
Write-Host "========================================"
Write-Host "成功: $successCount"
Write-Host "失败: $failedCount"
if ($failedProductIds.Count -gt 0) {
    Write-Host "失败的商品ID: $($failedProductIds -join ', ')"
}
Write-Host "========================================"
