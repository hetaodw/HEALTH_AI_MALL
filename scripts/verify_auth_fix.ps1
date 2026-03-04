# 认证问题修复验证脚本
# 用于验证数据库修复后的认证功能

$baseUrl = "http://localhost:8080/v1"
$testResults = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Authentication Fix Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 测试1: 重复注册测试（应该失败）
# ============================================
Write-Host "[Test 1] Duplicate Registration (should fail)" -ForegroundColor Yellow
$registerBody = @{
    username = "testuser1"
    password = "Test123456"
    email = "testuser1_duplicate@example.com"
    phone = "13800138999"
    role = "USER"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $registerBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "❌ FAIL: Duplicate registration should have failed but succeeded" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        Test = "Duplicate Registration"
        Expected = "Should fail with 400 error"
        Actual = "Succeeded (200 OK)"
        Status = "FAIL"
    }
} catch {
    Write-Host "✅ PASS: Duplicate registration correctly failed" -ForegroundColor Green
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "Duplicate Registration"
        Expected = "Should fail with 400 error"
        Actual = "Failed with error"
        Status = "PASS"
    }
}
Write-Host ""

# ============================================
# 测试2: 正确密码登录（应该成功）
# ============================================
Write-Host "[Test 2] Login with correct password (should succeed)" -ForegroundColor Yellow
$correctLoginBody = @{
    username = "testuser1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $correctLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ PASS: Login with correct password succeeded" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.userInfo.role)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "Correct Password Login"
        Expected = "Should succeed with token"
        Actual = "Succeeded with token"
        Status = "PASS"
    }
} catch {
    Write-Host "❌ FAIL: Login with correct password failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        Test = "Correct Password Login"
        Expected = "Should succeed with token"
        Actual = "Failed with error"
        Status = "FAIL"
    }
}
Write-Host ""

# ============================================
# 测试3: 错误密码登录（应该失败）
# ============================================
Write-Host "[Test 3] Login with wrong password (should fail)" -ForegroundColor Yellow
$wrongLoginBody = @{
    username = "testuser1"
    password = "WrongPassword123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $wrongLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "❌ FAIL: Login with wrong password should have failed but succeeded" -ForegroundColor Red
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "Wrong Password Login"
        Expected = "Should fail with 401 error"
        Actual = "Succeeded (200 OK)"
        Status = "FAIL"
    }
} catch {
    Write-Host "✅ PASS: Login with wrong password correctly failed" -ForegroundColor Green
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "Wrong Password Login"
        Expected = "Should fail with 401 error"
        Actual = "Failed with error"
        Status = "PASS"
    }
}
Write-Host ""

# ============================================
# 测试4: 新用户注册（应该成功）
# ============================================
Write-Host "[Test 4] New user registration (should succeed)" -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$newUserBody = @{
    username = "newuser_$timestamp"
    password = "Test123456"
    email = "newuser_$timestamp@example.com"
    phone = "13800138888"
    role = "USER"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $newUserBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ PASS: New user registration succeeded" -ForegroundColor Green
    $testResults += [PSCustomObject]@{
        Test = "New User Registration"
        Expected = "Should succeed with 200 OK"
        Actual = "Succeeded (200 OK)"
        Status = "PASS"
    }
} catch {
    Write-Host "❌ FAIL: New user registration failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        Test = "New User Registration"
        Expected = "Should succeed with 200 OK"
        Actual = "Failed with error"
        Status = "FAIL"
    }
}
Write-Host ""

# ============================================
# 测试5: 新用户登录（应该成功）
# ============================================
Write-Host "[Test 5] New user login (should succeed)" -ForegroundColor Yellow
$newUserLoginBody = @{
    username = "newuser_$timestamp"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $newUserLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ PASS: New user login succeeded" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "New User Login"
        Expected = "Should succeed with token"
        Actual = "Succeeded with token"
        Status = "PASS"
    }
} catch {
    Write-Host "❌ FAIL: New user login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        Test = "New User Login"
        Expected = "Should succeed with token"
        Actual = "Failed with error"
        Status = "FAIL"
    }
}
Write-Host ""

# ============================================
# 测试6: 商家账号登录（应该成功）
# ============================================
Write-Host "[Test 6] Merchant account login (should succeed)" -ForegroundColor Yellow
$merchantLoginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $merchantLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ PASS: Merchant account login succeeded" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.userInfo.role)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        Test = "Merchant Account Login"
        Expected = "Should succeed with token"
        Actual = "Succeeded with token"
        Status = "PASS"
    }
} catch {
    Write-Host "❌ FAIL: Merchant account login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        Test = "Merchant Account Login"
        Expected = "Should succeed with token"
        Actual = "Failed with error"
        Status = "FAIL"
    }
}
Write-Host ""

# ============================================
# 测试总结
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passedCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failedCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count

Write-Host "Total Tests: $($testResults.Count)" -ForegroundColor White
Write-Host "Passed: $passedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red
Write-Host ""

Write-Host "Detailed Test Results:" -ForegroundColor Cyan
$testResults | Format-Table -AutoSize

Write-Host ""
if ($failedCount -eq 0) {
    Write-Host "🎉 All tests passed! The authentication issues have been fixed." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed. Please review the results above." -ForegroundColor Yellow
}

$testResults | Export-Csv -Path "scripts\verify_auth_fix_results.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Test results saved to: scripts\verify_auth_fix_results.csv" -ForegroundColor Gray
