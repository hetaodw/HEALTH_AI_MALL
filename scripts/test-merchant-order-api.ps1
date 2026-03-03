$ErrorActionPreference = "Stop"

$baseUrl = "http://localhost:8080/v1"
$testResults = @()
$merchantToken = ""

function Write-TestHeader {
    param([string]$title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Invoke-ApiTest {
    param(
        [string]$testName,
        [string]$method,
        [string]$endpoint,
        [hashtable]$headers = @{},
        [hashtable]$queryParams = @{},
        [object]$body = $null,
        [int]$expectedCode = 200,
        [string]$description = ""
    )

    $startTime = Get-Date
    $statusCode = 0
    $response = $null
    $errorMessage = ""
    $success = $false

    try {
        $uri = "$baseUrl$endpoint"
        if ($queryParams.Count -gt 0) {
            $queryString = ($queryParams.GetEnumerator() | ForEach-Object { 
                "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString($_.Value))" 
            }) -join "&"
            $uri = "$($uri)?$queryString"
        }

        $params = @{
            Uri = $uri
            Method = $method
            Headers = $headers
        }

        if ($body -ne $null) {
            $params.Body = ($body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }

        $response = Invoke-RestMethod @params -ErrorAction Stop
        $statusCode = 200
        $success = ($response.code -eq $expectedCode)

        if (-not $success) {
            $errorMessage = "Expected code $expectedCode, got $($response.code): $($response.msg)"
        }
    } catch {
        $errorObj = $_.Exception.Response
        if ($errorObj) {
            $statusCode = [int]$errorObj.StatusCode
        } else {
            $statusCode = 500
        }
        $errorMessage = $_.Exception.Message
        $success = ($statusCode -eq $expectedCode)
    }

    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds

    $result = [PSCustomObject]@{
        TestName = $testName
        Method = $method
        Endpoint = $endpoint
        Description = $description
        ExpectedCode = $expectedCode
        ActualCode = $statusCode
        Success = $success
        Duration = [math]::Round($duration, 2)
        ErrorMessage = $errorMessage
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    $script:testResults += $result

    if ($success) {
        Write-Host "[PASS] $testName" -ForegroundColor Green
        Write-Host "  Status: $statusCode | Duration: $($result.Duration)ms" -ForegroundColor Gray
    } else {
        Write-Host "[FAIL] $testName" -ForegroundColor Red
        Write-Host "  Expected: $expectedCode | Actual: $statusCode" -ForegroundColor Red
        Write-Host "  Error: $errorMessage" -ForegroundColor Red
    }

    return $response
}

Write-TestHeader "Merchant Order Management API Testing"

Write-Host "`n[Step 1] Login as merchant to get token..." -ForegroundColor Yellow

$loginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    if ($loginResponse.code -eq 200) {
        $merchantToken = $loginResponse.data.token
        Write-Host "[OK] Merchant login successful" -ForegroundColor Green
        Write-Host "  Token: $($merchantToken.Substring(0, 20))..." -ForegroundColor Gray
    } else {
        Write-Host "[FAIL] Merchant login failed: $($loginResponse.msg)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[FAIL] Merchant login error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$authHeaders = @{
    "Authorization" = "Bearer $merchantToken"
}

Write-TestHeader "Test Case 1: Get Pending Orders"

Invoke-ApiTest -testName "Get Pending Orders - Empty List" `
    -method "GET" `
    -endpoint "/merchant/orders/pending" `
    -headers $authHeaders `
    -expectedCode 200 `
    -description "Retrieve all pending confirmation orders for current merchant"

Write-TestHeader "Test Case 2: Get All Merchant Orders"

Invoke-ApiTest -testName "Get All Orders - No Filter" `
    -method "GET" `
    -endpoint "/merchant/orders" `
    -headers $authHeaders `
    -expectedCode 200 `
    -description "Retrieve all orders for current merchant without status filter"

Invoke-ApiTest -testName "Get Orders - With Status Filter" `
    -method "GET" `
    -endpoint "/merchant/orders" `
    -headers $authHeaders `
    -queryParams @{ status = "PENDING_CONFIRMATION" } `
    -expectedCode 200 `
    -description "Retrieve orders filtered by PENDING_CONFIRMATION status"

Invoke-ApiTest -testName "Get Orders - Filter by CONFIRMED" `
    -method "GET" `
    -endpoint "/merchant/orders" `
    -headers $authHeaders `
    -queryParams @{ status = "CONFIRMED" } `
    -expectedCode 200 `
    -description "Retrieve orders filtered by CONFIRMED status"

Write-TestHeader "Test Case 3: Confirm Order"

Invoke-ApiTest -testName "Confirm Order - Invalid Order ID" `
    -method "POST" `
    -endpoint "/merchant/orders/999999/confirm" `
    -headers $authHeaders `
    -expectedCode 404 `
    -description "Attempt to confirm a non-existent order"

Invoke-ApiTest -testName "Confirm Order - Invalid Order ID Format" `
    -method "POST" `
    -endpoint "/merchant/orders/invalid/confirm" `
    -headers $authHeaders `
    -expectedCode 400 `
    -description "Attempt to confirm order with invalid ID format"

Write-TestHeader "Test Case 4: Reject Order"

$rejectBody = @{
    rejectReason = "库存不足"
}

Invoke-ApiTest -testName "Reject Order - Invalid Order ID" `
    -method "POST" `
    -endpoint "/merchant/orders/999999/reject" `
    -headers $authHeaders `
    -body $rejectBody `
    -expectedCode 404 `
    -description "Attempt to reject a non-existent order"

Invoke-ApiTest -testName "Reject Order - Missing Reject Reason" `
    -method "POST" `
    -endpoint "/merchant/orders/1/reject" `
    -headers $authHeaders `
    -body @{} `
    -expectedCode 400 `
    -description "Attempt to reject order without providing reject reason"

Invoke-ApiTest -testName "Reject Order - Invalid Order ID Format" `
    -method "POST" `
    -endpoint "/merchant/orders/invalid/reject" `
    -headers $authHeaders `
    -body $rejectBody `
    -expectedCode 400 `
    -description "Attempt to reject order with invalid ID format"

Write-TestHeader "Test Case 5: Authentication & Authorization"

Invoke-ApiTest -testName "Get Pending Orders - No Token" `
    -method "GET" `
    -endpoint "/merchant/orders/pending" `
    -expectedCode 401 `
    -description "Attempt to access merchant endpoint without authentication"

Invoke-ApiTest -testName "Get Pending Orders - Invalid Token" `
    -method "GET" `
    -endpoint "/merchant/orders/pending" `
    -headers @{ "Authorization" = "Bearer invalid_token_12345" } `
    -expectedCode 401 `
    -description "Attempt to access merchant endpoint with invalid token"

Write-Host "`n[Step 2] Login as user to get user token..." -ForegroundColor Yellow

$userLoginBody = @{
    username = "testuser1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $userLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $userLoginBody -ContentType "application/json"
    if ($userLoginResponse.code -eq 200) {
        $userToken = $userLoginResponse.data.token
        Write-Host "[OK] User login successful" -ForegroundColor Green
        Write-Host "  Token: $($userToken.Substring(0, 20))..." -ForegroundColor Gray
        
        $userHeaders = @{
            "Authorization" = "Bearer $userToken"
        }
        
        Invoke-ApiTest -testName "Get Pending Orders - User Token" `
            -method "GET" `
            -endpoint "/merchant/orders/pending" `
            -headers $userHeaders `
            -expectedCode 403 `
            -description "Attempt to access merchant endpoint with user role token"
    } else {
        Write-Host "[FAIL] User login failed: $($userLoginResponse.msg)" -ForegroundColor Red
    }
} catch {
    Write-Host "[FAIL] User login error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-TestHeader "Test Summary"

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Success }).Count
$failedTests = $totalTests - $passedTests
$passRate = [math]::Round(($passedTests / $totalTests) * 100, 2)

$avgDuration = ($testResults | Measure-Object -Property Duration -Average).Average
$maxDuration = ($testResults | Measure-Object -Property Duration -Maximum).Maximum
$minDuration = ($testResults | Measure-Object -Property Duration -Minimum).Minimum

Write-Host "`nTotal Tests: $totalTests" -ForegroundColor Cyan
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Pass Rate: $passRate%" -ForegroundColor Cyan
Write-Host "`nPerformance Metrics:" -ForegroundColor Cyan
Write-Host "  Average Response Time: $([math]::Round($avgDuration, 2))ms" -ForegroundColor Gray
Write-Host "  Min Response Time: $([math]::Round($minDuration, 2))ms" -ForegroundColor Gray
Write-Host "  Max Response Time: $([math]::Round($maxDuration, 2))ms" -ForegroundColor Gray

$reportPath = "merchant_order_api_test_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nTest report saved to: $reportPath" -ForegroundColor Cyan

$failedTestsList = $testResults | Where-Object { -not $_.Success }
if ($failedTestsList.Count -gt 0) {
    Write-Host "`nFailed Tests Details:" -ForegroundColor Red
    $failedTestsList | ForEach-Object {
        Write-Host "  - $($_.TestName): $($_.ErrorMessage)" -ForegroundColor Red
    }
}

return $testResults
