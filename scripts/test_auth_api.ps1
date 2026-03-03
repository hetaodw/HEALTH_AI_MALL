$baseUrl = "http://localhost:8080/v1"
$testResults = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Authentication API Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: User Registration
Write-Host "[Test 1] User Registration" -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$registerBody = @{
    username = "testuser_$timestamp"
    password = "Test123456"
    avatarUrl = "http://example.com/avatar.jpg"
    email = "testuser_$timestamp@example.com"
    phone = "13800138000"
    role = "USER"
    remarks = "Test User"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $registerBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: User registration successful" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "User Registration"
        Endpoint = "POST /v1/auth/register"
        Status = "PASS"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "FAIL: User registration failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "User Registration"
        Endpoint = "POST /v1/auth/register"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 2: Duplicate Registration (should fail)
Write-Host "[Test 2] Duplicate Registration (should fail)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $registerBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "FAIL: Duplicate registration should have failed but succeeded" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Duplicate Registration"
        Endpoint = "POST /v1/auth/register"
        Status = "FAIL (expected to fail but succeeded)"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "PASS: Duplicate registration correctly failed" -ForegroundColor Green
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Duplicate Registration"
        Endpoint = "POST /v1/auth/register"
        Status = "PASS (correctly failed)"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 3: User Login
Write-Host "[Test 3] User Login" -ForegroundColor Yellow
$loginBody = @{
    username = "testuser_$timestamp"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: User login successful" -ForegroundColor Green
    Write-Host "  Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    $token = $response.data.token
    $userId = $response.data.userInfo.id
    $testResults += [PSCustomObject]@{
        TestCase = "User Login"
        Endpoint = "POST /v1/auth/login"
        Status = "PASS"
        Response = "Token obtained, User ID: $userId"
    }
} catch {
    Write-Host "FAIL: User login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "User Login"
        Endpoint = "POST /v1/auth/login"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 4: Wrong Password Login (should fail)
Write-Host "[Test 4] Wrong Password Login (should fail)" -ForegroundColor Yellow
$wrongPasswordBody = @{
    username = "testuser_$timestamp"
    password = "WrongPassword123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $wrongPasswordBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "FAIL: Wrong password login should have failed but succeeded" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Wrong Password Login"
        Endpoint = "POST /v1/auth/login"
        Status = "FAIL (expected to fail but succeeded)"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "PASS: Wrong password login correctly failed" -ForegroundColor Green
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Wrong Password Login"
        Endpoint = "POST /v1/auth/login"
        Status = "PASS (correctly failed)"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 5: User Logout
Write-Host "[Test 5] User Logout" -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/logout" -Method Post -Headers $headers -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: User logout successful" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "User Logout"
        Endpoint = "POST /v1/auth/logout"
        Status = "PASS"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "FAIL: User logout failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "User Logout"
        Endpoint = "POST /v1/auth/logout"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 6: Login with existing account (testuser1)
Write-Host "[Test 6] Login with existing account (testuser1)" -ForegroundColor Yellow
$loginBody2 = @{
    username = "testuser1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody2 -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: Existing account login successful" -ForegroundColor Green
    Write-Host "  Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.userInfo.role)" -ForegroundColor Gray
    $global:userToken = $response.data.token
    $global:userId = $response.data.userInfo.id
    $testResults += [PSCustomObject]@{
        TestCase = "Existing Account Login"
        Endpoint = "POST /v1/auth/login"
        Status = "PASS"
        Response = "Token obtained, User ID: $($response.data.userInfo.id), Role: $($response.data.userInfo.role)"
    }
} catch {
    Write-Host "FAIL: Existing account login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Existing Account Login"
        Endpoint = "POST /v1/auth/login"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 7: Merchant Account Login
Write-Host "[Test 7] Merchant Account Login (testmerchant1)" -ForegroundColor Yellow
$merchantLoginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $merchantLoginBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: Merchant account login successful" -ForegroundColor Green
    Write-Host "  Token: $($response.data.token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host "  User ID: $($response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.userInfo.username)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.userInfo.role)" -ForegroundColor Gray
    $global:merchantToken = $response.data.token
    $global:merchantId = $response.data.userInfo.id
    $testResults += [PSCustomObject]@{
        TestCase = "Merchant Account Login"
        Endpoint = "POST /v1/auth/login"
        Status = "PASS"
        Response = "Token obtained, User ID: $($response.data.userInfo.id), Role: $($response.data.userInfo.role)"
    }
} catch {
    Write-Host "FAIL: Merchant account login failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Merchant Account Login"
        Endpoint = "POST /v1/auth/login"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passedCount = ($testResults | Where-Object { $_.Status -like "*PASS*" }).Count
$failedCount = ($testResults | Where-Object { $_.Status -like "*FAIL*" -and $_.Status -notlike "*correctly failed*" }).Count

Write-Host "Total Tests: $($testResults.Count)" -ForegroundColor White
Write-Host "Passed: $passedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red
Write-Host ""

Write-Host "Detailed Test Results:" -ForegroundColor Cyan
$testResults | Format-Table -AutoSize

Write-Host ""
Write-Host "Testing Complete!" -ForegroundColor Green

$testResults | Export-Csv -Path "scripts\test_auth_api_results.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Test results saved to: scripts\test_auth_api_results.csv" -ForegroundColor Gray
