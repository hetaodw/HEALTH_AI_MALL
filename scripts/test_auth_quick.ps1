$baseUrl = "http://localhost:8080/v1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API 功能测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 测试1: 重复注册
Write-Host "[Test 1] 重复注册测试（应该失败）" -ForegroundColor Yellow
$registerBody = @{
    username = "testuser1"
    password = "Test123456"
    email = "testuser1_duplicate@example.com"
    phone = "13800138999"
    role = "USER"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $registerBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "FAIL: 重复注册成功（不应该成功）" -ForegroundColor Red
    Write-Host "响应: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
} catch {
    Write-Host "PASS: 重复注册失败（正确）" -ForegroundColor Green
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Gray
}
Write-Host ""

# 测试2: 正确密码登录
Write-Host "[Test 2] 正确密码登录（应该成功）" -ForegroundColor Yellow
$correctLoginBody = @{
    username = "testuser1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $correctLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: 正确密码登录成功" -ForegroundColor Green
    Write-Host "用户ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "用户名: $($response.data.userInfo.username)" -ForegroundColor Gray
} catch {
    Write-Host "FAIL: 正确密码登录失败: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 测试3: 错误密码登录
Write-Host "[Test 3] 错误密码登录（应该失败）" -ForegroundColor Yellow
$wrongLoginBody = @{
    username = "testuser1"
    password = "WrongPassword123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $wrongLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "FAIL: 错误密码登录成功（不应该成功）" -ForegroundColor Red
    Write-Host "响应: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
} catch {
    Write-Host "PASS: 错误密码登录失败（正确）" -ForegroundColor Green
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
