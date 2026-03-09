$baseUrl = "http://localhost:8080/v1"

Write-Host "=== 并行处理性能测试 ===" -ForegroundColor Green
Write-Host ""

$loginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $merchantToken = $loginResponse.data.token
    Write-Host "登录成功" -ForegroundColor Green
} catch {
    Write-Host "登录失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $merchantToken"
    "Content-Type" = "application/json"
}

Write-Host ""
Write-Host "测试批量生成标签（5个商品）..." -ForegroundColor Cyan
$startTime = Get-Date
$body = @{
    productIds = @(1, 2, 3, 4, 5)
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products/tags/batch/generate" -Method POST -Headers $headers -Body $body
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    Write-Host ""
    Write-Host "测试结果:" -ForegroundColor Green
    Write-Host "  状态: $($response.code)" -ForegroundColor Gray
    Write-Host "  成功: $($response.data.successCount)" -ForegroundColor Gray
    Write-Host "  失败: $($response.data.failedCount)" -ForegroundColor Gray
    Write-Host "  响应时间: ${duration}ms" -ForegroundColor Yellow
    Write-Host "  消息: $($response.message)" -ForegroundColor Gray
    
    if ($duration -lt 2000) {
        Write-Host ""
        Write-Host "✅ 性能优化成功！响应时间从 17秒 降至 ${duration}ms" -ForegroundColor Green
    } elseif ($duration -lt 5000) {
        Write-Host ""
        Write-Host "⚠️ 性能有所改善，但仍有优化空间。响应时间: ${duration}ms" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "❌ 性能优化效果不佳。响应时间: ${duration}ms" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "测试失败: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "响应内容: $responseBody" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== 测试完成 ===" -ForegroundColor Green
