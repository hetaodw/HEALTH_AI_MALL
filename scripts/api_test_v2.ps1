$ErrorActionPreference = "Stop"
$BaseUrl = "http://localhost:8080/v1"
$TestResults = @()
$MerchantToken = $null
$UserToken = $null

$script:TestCount = 0
$script:PassCount = 0
$script:FailCount = 0
$script:ResponseTimes = @()

function Write-TestHeader {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Details = "",
        [double]$ResponseTime = 0
    )
    
    $script:TestCount++
    
    if ($Passed) {
        $script:PassCount++
        Write-Host "[PASS] " -NoNewline -ForegroundColor Green
        Write-Host $TestName -ForegroundColor White
        if ($Message) { Write-Host "       $Message" -ForegroundColor Gray }
    } else {
        $script:FailCount++
        Write-Host "[FAIL] " -NoNewline -ForegroundColor Red
        Write-Host $TestName -ForegroundColor White
        if ($Message) { Write-Host "       $Message" -ForegroundColor Red }
    }
    
    if ($Details) { Write-Host "       Details: $Details" -ForegroundColor Gray }
    if ($ResponseTime -gt 0) { 
        $script:ResponseTimes += $ResponseTime
        Write-Host "       Response Time: $([math]::Round($ResponseTime, 2))ms" -ForegroundColor Gray 
    }
    
    $TestResults += [PSCustomObject]@{
        TestName = $TestName
        Status = if ($Passed) { "PASS" } else { "FAIL" }
        Message = $Message
        Details = $Details
        ResponseTime = $ResponseTime
    }
}

function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [object]$Body = $null
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $url = "$BaseUrl$Endpoint"
        $params = @{
            Method = $Method
            Uri = $url
            Headers = $Headers
        }
        
        if ($Body) {
            if ($Method -in @("POST", "PUT", "PATCH")) {
                $params.Body = $Body | ConvertTo-Json -Depth 10
                $params.ContentType = "application/json"
            }
        }
        
        $response = Invoke-RestMethod @params
        $stopwatch.Stop()
        
        return [PSCustomObject]@{
            Success = $true
            Response = $response
            StatusCode = 200
            ResponseTime = $stopwatch.ElapsedMilliseconds
            Error = $null
        }
    }
    catch {
        $stopwatch.Stop()
        $statusCode = if ($_.Exception.Response) { 
            [int]$_.Exception.Response.StatusCode 
        } else { 
            0 
        }
        
        return [PSCustomObject]@{
            Success = $false
            Response = $null
            StatusCode = $statusCode
            ResponseTime = $stopwatch.ElapsedMilliseconds
            Error = $_.Exception.Message
        }
    }
}

function Invoke-FormApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [hashtable]$FormData = $null
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $url = "$BaseUrl$Endpoint"
        
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = @()
        
        foreach ($key in $FormData.Keys) {
            $value = $FormData[$key]
            if ($value -ne $null) {
                $bodyLines += "--$boundary"
                $bodyLines += "Content-Disposition: form-data; name=`"$key`""
                $bodyLines += ""
                $bodyLines += $value.ToString()
            }
        }
        
        $bodyLines += "--$boundary--"
        $bodyLines += ""
        
        $body = $bodyLines -join $LF
        
        $contentType = "multipart/form-data; boundary=$boundary"
        $Headers["Content-Type"] = $contentType
        
        $params = @{
            Method = $Method
            Uri = $url
            Headers = $Headers
            Body = [System.Text.Encoding]::UTF8.GetBytes($body)
        }
        
        $response = Invoke-RestMethod @params
        $stopwatch.Stop()
        
        return [PSCustomObject]@{
            Success = $true
            Response = $response
            StatusCode = 200
            ResponseTime = $stopwatch.ElapsedMilliseconds
            Error = $null
        }
    }
    catch {
        $stopwatch.Stop()
        $statusCode = if ($_.Exception.Response) { 
            [int]$_.Exception.Response.StatusCode 
        } else { 
            0 
        }
        
        return [PSCustomObject]@{
            Success = $false
            Response = $null
            StatusCode = $statusCode
            ResponseTime = $stopwatch.ElapsedMilliseconds
            Error = $_.Exception.Message
        }
    }
}

Write-TestHeader "AUTHENTICATION TESTS"

Write-Host "Testing merchant login..." -ForegroundColor Yellow
$loginBody = @{
    username = "testmerchant1"
    password = "Test123456"
}

$result = Invoke-ApiCall -Method "POST" -Endpoint "/auth/login" -Body $loginBody

if ($result.Success -and $result.Response.code -eq 200) {
    $MerchantToken = $result.Response.data.token
    Write-TestResult -TestName "Merchant Login" -Passed $true -Message "Token obtained successfully" -ResponseTime $result.ResponseTime
    Write-Host "       Merchant ID: $($result.Response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "       Role: $($result.Response.data.userInfo.role)" -ForegroundColor Gray
} else {
    Write-TestResult -TestName "Merchant Login" -Passed $false -Message "Login failed" -Details $result.Error
}

Write-Host "`nTesting user login..." -ForegroundColor Yellow
$userLoginBody = @{
    username = "testuser1"
    password = "Test123456"
}

$result = Invoke-ApiCall -Method "POST" -Endpoint "/auth/login" -Body $userLoginBody

if ($result.Success -and $result.Response.code -eq 200) {
    $UserToken = $result.Response.data.token
    Write-TestResult -TestName "User Login" -Passed $true -Message "Token obtained successfully" -ResponseTime $result.ResponseTime
    Write-Host "       User ID: $($result.Response.data.userInfo.id)" -ForegroundColor Gray
    Write-Host "       Role: $($result.Response.data.userInfo.role)" -ForegroundColor Gray
} else {
    Write-TestResult -TestName "User Login" -Passed $false -Message "Login failed" -Details $result.Error
}

Write-TestHeader "PRODUCT MANAGEMENT TESTS (FORM-DATA)"

$headers = @{
    Authorization = "Bearer $MerchantToken"
}

Write-Host "`nTest Case 1: Add product with AUTO mode (form-data)..." -ForegroundColor Yellow
$product1FormData = @{
    title = "Test Product - Auto Confirm"
    category = "Health"
    price = "99.00"
    stock = "100"
    description = "Test product description"
    status = "ON_SALE"
    autoConfirmMode = "AUTO"
}

$result = Invoke-FormApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product1FormData

if ($result.Success -and $result.Response.code -eq 200) {
    $product1Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "AUTO" -and $result.Response.data.autoConfirmCondition -eq $null
    Write-TestResult -TestName "Add Product - AUTO Mode (Form-Data)" -Passed $passed -Message "Product ID: $product1Id" -ResponseTime $result.ResponseTime
    if (-not $passed) {
        Write-TestResult -TestName "Add Product - AUTO Mode Validation" -Passed $false -Message "autoConfirmMode or autoConfirmCondition incorrect"
    }
} else {
    Write-TestResult -TestName "Add Product - AUTO Mode (Form-Data)" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 2: Add product with MANUAL mode (form-data)..." -ForegroundColor Yellow
$product2FormData = @{
    title = "Test Product - Manual Confirm"
    category = "Health"
    price = "199.00"
    stock = "50"
    description = "Manual confirm product"
    status = "ON_SALE"
    autoConfirmMode = "MANUAL"
}

$result = Invoke-FormApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product2FormData

if ($result.Success -and $result.Response.code -eq 200) {
    $product2Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "MANUAL"
    Write-TestResult -TestName "Add Product - MANUAL Mode (Form-Data)" -Passed $passed -Message "Product ID: $product2Id" -ResponseTime $result.ResponseTime
} else {
    Write-TestResult -TestName "Add Product - MANUAL Mode (Form-Data)" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 3: Add product with SMART mode (form-data)..." -ForegroundColor Yellow
$smartCondition = '{"minOrderAmount":100,"stockThreshold":10}'

$product3FormData = @{
    title = "Test Product - Smart Confirm"
    category = "Health"
    price = "299.00"
    stock = "200"
    description = "Smart confirm product"
    status = "ON_SALE"
    autoConfirmMode = "SMART"
    autoConfirmCondition = $smartCondition
}

$result = Invoke-FormApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product3FormData

if ($result.Success -and $result.Response.code -eq 200) {
    $product3Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "SMART" -and $result.Response.data.autoConfirmCondition -ne $null
    Write-TestResult -TestName "Add Product - SMART Mode (Form-Data)" -Passed $passed -Message "Product ID: $product3Id" -ResponseTime $result.ResponseTime
} else {
    Write-TestResult -TestName "Add Product - SMART Mode (Form-Data)" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 5: Get product list..." -ForegroundColor Yellow
$result = Invoke-ApiCall -Method "GET" -Endpoint "/merchant/products?page=1&size=10" -Headers $headers

if ($result.Success -and $result.Response.code -eq 200) {
    $passed = $result.Response.data.list -is [array] -and $result.Response.data.list.Count -gt 0
    $firstProduct = $result.Response.data.list[0]
    $hasAutoConfirmMode = $firstProduct.PSObject.Properties.Name -contains "autoConfirmMode"
    Write-TestResult -TestName "Get Product List" -Passed $passed -Message "Found $($result.Response.data.list.Count) products" -ResponseTime $result.ResponseTime
    if ($hasAutoConfirmMode) {
        Write-TestResult -TestName "Product List - Contains autoConfirmMode" -Passed $true -Message "Field present in response"
    } else {
        Write-TestResult -TestName "Product List - Contains autoConfirmMode" -Passed $false -Message "Field missing in response"
    }
} else {
    Write-TestResult -TestName "Get Product List" -Passed $false -Message "Failed to get product list" -Details $result.Error
}

Write-Host "`nTest Case 7: Batch update - all to AUTO..." -ForegroundColor Yellow
if ($product1Id -and $product2Id -and $product3Id) {
    $batchBody = @{
        productIds = @($product1Id, $product2Id, $product3Id)
        autoConfirmMode = "AUTO"
    }

    $result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.successCount -eq 3 -and $result.Response.data.failedCount -eq 0
        Write-TestResult -TestName "Batch Update - All to AUTO" -Passed $passed -Message "Success: $($result.Response.data.successCount), Failed: $($result.Response.data.failedCount)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Batch Update - All to AUTO" -Passed $false -Message "Batch update failed" -Details $result.Error
    }
}

Write-TestHeader "ORDER CREATION TESTS"

$userHeaders = @{
    Authorization = "Bearer $UserToken"
}

Write-Host "`nTest Case 9: Create order - AUTO mode (sufficient stock)..." -ForegroundColor Yellow
if ($product1Id) {
    $orderBody = @{
        addressId = 1
        items = @(
            @{ productId = $product1Id; quantity = 5 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.status -eq "PENDING_PAYMENT" -and $result.Response.data.autoConfirmed -eq $true
        Write-TestResult -TestName "Create Order - AUTO Mode" -Passed $passed -Message "Order ID: $($result.Response.data.id), Status: $($result.Response.data.status)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Create Order - AUTO Mode" -Passed $false -Message "Failed to create order" -Details $result.Error
    }
}

Write-Host "`nTest Case 10: Create order - MANUAL mode..." -ForegroundColor Yellow
if ($product2Id) {
    $orderBody = @{
        addressId = 1
        items = @(
            @{ productId = $product2Id; quantity = 2 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.status -eq "PENDING_CONFIRMATION" -and $result.Response.data.autoConfirmed -eq $false
        Write-TestResult -TestName "Create Order - MANUAL Mode" -Passed $passed -Message "Order ID: $($result.Response.data.id), Status: $($result.Response.data.status)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Create Order - MANUAL Mode" -Passed $false -Message "Failed to create order" -Details $result.Error
    }
}

Write-Host "`nTest Case 11: Create order - SMART mode (condition met)..." -ForegroundColor Yellow
if ($product3Id) {
    $orderBody = @{
        addressId = 1
        items = @(
            @{ productId = $product3Id; quantity = 1 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody

    if ($result.Success -and $result.Response.code -eq 200) {
        $totalAmount = $result.Response.data.totalAmount
        $passed = $result.Response.data.autoConfirmed -eq $true
        Write-TestResult -TestName "Create Order - SMART Mode (Condition Met)" -Passed $passed -Message "Order ID: $($result.Response.data.id), Amount: $totalAmount, AutoConfirmed: $($result.Response.data.autoConfirmed)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Create Order - SMART Mode (Condition Met)" -Passed $false -Message "Failed to create order" -Details $result.Error
    }
}

Write-TestHeader "BOUNDARY CONDITION TESTS"

Write-Host "`nTest Case 13: Batch update - empty product IDs..." -ForegroundColor Yellow
$batchBody3 = @{
    productIds = @()
    autoConfirmMode = "AUTO"
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody3

$passed = -not $result.Success -or $result.Response.code -ne 200
Write-TestResult -TestName "Batch Update - Empty Product IDs" -Passed $passed -Message "Expected to fail with empty list" -ResponseTime $result.ResponseTime

Write-Host "`nTest Case 14: Batch update - null autoConfirmMode..." -ForegroundColor Yellow
$batchBody4 = @{
    productIds = @($product1Id, $product2Id)
    autoConfirmMode = $null
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody4

$passed = -not $result.Success -or $result.Response.code -ne 200
Write-TestResult -TestName "Batch Update - Null AutoConfirmMode" -Passed $passed -Message "Expected to fail with null mode" -ResponseTime $result.ResponseTime

Write-Host "`nTest Case 16: AUTO mode - insufficient stock..." -ForegroundColor Yellow
if ($product1Id) {
    $orderBody2 = @{
        addressId = 1
        items = @(
            @{ productId = $product1Id; quantity = 1000 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody2

    $passed = -not $result.Success -or $result.Response.code -eq 400
    Write-TestResult -TestName "Create Order - AUTO Insufficient Stock" -Passed $passed -Message "Expected to fail with insufficient stock" -ResponseTime $result.ResponseTime
}

Write-Host "`nTest Case 17: Mixed mode order..." -ForegroundColor Yellow
if ($product1Id -and $product2Id) {
    $orderBody3 = @{
        addressId = 1
        items = @(
            @{ productId = $product1Id; quantity = 2 }
            @{ productId = $product2Id; quantity = 1 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody3

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.status -eq "PENDING_CONFIRMATION" -and $result.Response.data.autoConfirmed -eq $false
        Write-TestResult -TestName "Create Order - Mixed Mode" -Passed $passed -Message "Order ID: $($result.Response.data.id), Status: $($result.Response.data.status)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Create Order - Mixed Mode" -Passed $false -Message "Failed to create order" -Details $result.Error
    }
}

Write-TestHeader "PERFORMANCE TEST"

Write-Host "`nTest Case 18: Batch update performance (100 products)..." -ForegroundColor Yellow
$productIds = 1..100 | ForEach-Object { $_ }
$batchBody5 = @{
    productIds = $productIds
    autoConfirmMode = "AUTO"
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody5

if ($result.Success) {
    $passed = $result.ResponseTime -lt 5000
    Write-TestResult -TestName "Batch Update - Performance (100 products)" -Passed $passed -Message "Response Time: $([math]::Round($result.ResponseTime, 2))ms" -ResponseTime $result.ResponseTime
} else {
    Write-TestResult -TestName "Batch Update - Performance (100 products)" -Passed $false -Message "Batch update failed" -Details $result.Error
}

Write-TestHeader "TEST SUMMARY"

Write-Host "`nTotal Tests: $script:TestCount" -ForegroundColor White
Write-Host "Passed: $script:PassCount" -ForegroundColor Green
Write-Host "Failed: $script:FailCount" -ForegroundColor Red

if ($script:ResponseTimes.Count -gt 0) {
    $avgTime = ($script:ResponseTimes | Measure-Object -Average).Average
    $minTime = ($script:ResponseTimes | Measure-Object -Minimum).Minimum
    $maxTime = ($script:ResponseTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "`nPerformance Metrics:" -ForegroundColor Cyan
    Write-Host "  Average Response Time: $([math]::Round($avgTime, 2))ms" -ForegroundColor White
    Write-Host "  Minimum Response Time: $([math]::Round($minTime, 2))ms" -ForegroundColor White
    Write-Host "  Maximum Response Time: $([math]::Round($maxTime, 2))ms" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST EXECUTION COMPLETED" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = "d:\26bs\test_results_$timestamp.csv"
$TestResults | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "Test results exported to: $csvPath" -ForegroundColor Yellow
