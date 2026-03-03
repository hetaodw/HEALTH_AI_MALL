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

function Invoke-MultipartApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Headers = @{},
        [hashtable]$FormData = @{},
        [string]$CoverImagePath = $null,
        [array]$DetailImagePaths = @()
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $url = "$BaseUrl$Endpoint"
        
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = @()
        
        foreach ($key in $FormData.Keys) {
            $value = $FormData[$key]
            if ($value -is [array]) {
                foreach ($item in $value) {
                    $bodyLines += "--$boundary"
                    $bodyLines += "Content-Disposition: form-data; name=`"$key`""
                    $bodyLines += ""
                    $bodyLines += $item
                }
            } else {
                $bodyLines += "--$boundary"
                $bodyLines += "Content-Disposition: form-data; name=`"$key`""
                $bodyLines += ""
                $bodyLines += $value
            }
        }
        
        if ($CoverImagePath -and (Test-Path $CoverImagePath)) {
            $fileName = Split-Path $CoverImagePath -Leaf
            $fileBytes = [System.IO.File]::ReadAllBytes($CoverImagePath)
            $bodyLines += "--$boundary"
            $bodyLines += "Content-Disposition: form-data; name=`"coverImage`"; filename=`"$fileName`""
            $bodyLines += "Content-Type: application/octet-stream"
            $bodyLines += ""
            $bodyLines += [System.Text.Encoding]::ASCII.GetString($fileBytes)
        }
        
        foreach ($imgPath in $DetailImagePaths) {
            if ($imgPath -and (Test-Path $imgPath)) {
                $fileName = Split-Path $imgPath -Leaf
                $fileBytes = [System.IO.File]::ReadAllBytes($imgPath)
                $bodyLines += "--$boundary"
                $bodyLines += "Content-Disposition: form-data; name=`"detailImages`"; filename=`"$fileName`""
                $bodyLines += "Content-Type: application/octet-stream"
                $bodyLines += ""
                $bodyLines += [System.Text.Encoding]::ASCII.GetString($fileBytes)
            }
        }
        
        $bodyLines += "--$boundary--"
        $bodyLines += ""
        
        $body = $bodyLines -join $LF
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        
        $requestHeaders = @{
            Authorization = $Headers.Authorization
            "Content-Type" = "multipart/form-data; boundary=$boundary"
        }
        
        $params = @{
            Method = $Method
            Uri = $url
            Headers = $requestHeaders
            Body = $bodyBytes
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

function Create-TestImage {
    param(
        [string]$OutputPath,
        [int]$Width = 100,
        [int]$Height = 100,
        [string]$Color = "Blue"
    )
    
    try {
        Add-Type -AssemblyName System.Drawing
        $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.Clear([System.Drawing.Color]::$Color)
        $graphics.DrawString("TEST", 
            (New-Object System.Drawing.Font("Arial", 12)), 
            [System.Drawing.Brushes]::White, 
            10, 40)
        $graphics.Dispose()
        
        $directory = Split-Path $OutputPath
        if (-not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        
        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $bitmap.Dispose()
        
        Write-Host "Created test image: $OutputPath" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "Failed to create test image: $_" -ForegroundColor Red
        return $false
    }
}

Write-TestHeader "PREPARATION - Creating Test Images"

$testCoverImage = "d:\26bs\test_images\test_cover.jpg"
$testDetailImage = "d:\26bs\test_images\test_detail.jpg"

$coverCreated = Create-TestImage -OutputPath $testCoverImage -Width 200 -Height 200 -Color "Blue"
$detailCreated = Create-TestImage -OutputPath $testDetailImage -Width 400 -Height 300 -Color "Green"

if ($coverCreated -and $detailCreated) {
    Write-TestResult -TestName "Test Image Creation" -Passed $true -Message "Test images created successfully"
} else {
    Write-TestResult -TestName "Test Image Creation" -Passed $false -Message "Failed to create test images"
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

Write-TestHeader "PRODUCT MANAGEMENT TESTS"

$headers = @{
    Authorization = "Bearer $MerchantToken"
}

Write-Host "`nTest Case 1: Add product with AUTO mode..." -ForegroundColor Yellow
$product1FormData = @{
    title = "Test Product - Auto Confirm"
    category = "Health"
    price = "99.00"
    stock = "100"
    description = "Test product description"
    status = "ON_SALE"
    autoConfirmMode = "AUTO"
}

$result = Invoke-MultipartApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product1FormData -CoverImagePath $testCoverImage

if ($result.Success -and $result.Response.code -eq 200) {
    $product1Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "AUTO" -and $result.Response.data.autoConfirmCondition -eq $null
    Write-TestResult -TestName "Add Product - AUTO Mode" -Passed $passed -Message "Product ID: $product1Id" -ResponseTime $result.ResponseTime
    if (-not $passed) {
        Write-TestResult -TestName "Add Product - AUTO Mode Validation" -Passed $false -Message "autoConfirmMode or autoConfirmCondition incorrect"
    }
} else {
    Write-TestResult -TestName "Add Product - AUTO Mode" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 2: Add product with MANUAL mode..." -ForegroundColor Yellow
$product2FormData = @{
    title = "Test Product - Manual Confirm"
    category = "Health"
    price = "199.00"
    stock = "50"
    description = "Manual confirm product"
    status = "ON_SALE"
    autoConfirmMode = "MANUAL"
}

$result = Invoke-MultipartApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product2FormData -CoverImagePath $testCoverImage

if ($result.Success -and $result.Response.code -eq 200) {
    $product2Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "MANUAL"
    Write-TestResult -TestName "Add Product - MANUAL Mode" -Passed $passed -Message "Product ID: $product2Id" -ResponseTime $result.ResponseTime
} else {
    Write-TestResult -TestName "Add Product - MANUAL Mode" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 3: Add product with SMART mode..." -ForegroundColor Yellow
$smartCondition = @{
    minOrderAmount = 100
    stockThreshold = 10
} | ConvertTo-Json -Compress

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

$result = Invoke-MultipartApiCall -Method "POST" -Endpoint "/merchant/products" -Headers $headers -FormData $product3FormData -CoverImagePath $testCoverImage

if ($result.Success -and $result.Response.code -eq 200) {
    $product3Id = $result.Response.data.id
    $passed = $result.Response.data.autoConfirmMode -eq "SMART" -and $result.Response.data.autoConfirmCondition -ne $null
    Write-TestResult -TestName "Add Product - SMART Mode" -Passed $passed -Message "Product ID: $product3Id" -ResponseTime $result.ResponseTime
} else {
    Write-TestResult -TestName "Add Product - SMART Mode" -Passed $false -Message "Failed to create product" -Details $result.Error
}

Write-Host "`nTest Case 4: Update product - change AUTO to SMART..." -ForegroundColor Yellow
if ($product1Id) {
    $smartCondition2 = @{
        minOrderAmount = 50
        maxOrderAmount = 500
        minUserRating = 4.0
        stockThreshold = 20
    } | ConvertTo-Json -Compress

    $updateFormData = @{
        title = "Test Product - Updated"
        category = "Health"
        price = "89.00"
        stock = "80"
        description = "Updated description"
        status = "ON_SALE"
        autoConfirmMode = "SMART"
        autoConfirmCondition = $smartCondition2
    }

    $result = Invoke-MultipartApiCall -Method "PUT" -Endpoint "/merchant/products/$product1Id" -Headers $headers -FormData $updateFormData -CoverImagePath $testCoverImage

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.autoConfirmMode -eq "SMART"
        Write-TestResult -TestName "Update Product - Change to SMART" -Passed $passed -Message "Product ID: $product1Id" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Update Product - Change to SMART" -Passed $false -Message "Failed to update product" -Details $result.Error
    }
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

Write-Host "`nTest Case 6: Get product details..." -ForegroundColor Yellow
if ($product1Id) {
    $result = Invoke-ApiCall -Method "GET" -Endpoint "/merchant/products/$product1Id" -Headers $headers

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.id -eq $product1Id
        Write-TestResult -TestName "Get Product Details" -Passed $passed -Message "Product ID: $product1Id" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Get Product Details" -Passed $false -Message "Failed to get product details" -Details $result.Error
    }
}

Write-Host "`nTest Case 7: Batch update - all to AUTO..." -ForegroundColor Yellow
if ($product1Id -and $product2Id -and $product3Id) {
    $batchBody = @{
        productIds = @($product1Id, $product3Id)
        autoConfirmMode = "AUTO"
    }

    $result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.successCount -eq 2 -and $result.Response.data.failedCount -eq 0
        Write-TestResult -TestName "Batch Update - All to AUTO" -Passed $passed -Message "Success: $($result.Response.data.successCount), Failed: $($result.Response.data.failedCount)" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Batch Update - All to AUTO" -Passed $false -Message "Batch update failed" -Details $result.Error
    }
}

Write-Host "`nTest Case 8: Batch update - partial failure..." -ForegroundColor Yellow
$batchBody2 = @{
    productIds = @(999, 1000)
    autoConfirmMode = "MANUAL"
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody2

if ($result.Success -and $result.Response.code -eq 200) {
    $passed = $result.Response.data.successCount -eq 0 -and $result.Response.data.failedCount -eq 2
    Write-TestResult -TestName "Batch Update - Partial Failure" -Passed $passed -Message "Success: $($result.Response.data.successCount), Failed: $($result.Response.data.failedCount)" -ResponseTime $result.ResponseTime
    if ($result.Response.data.failedProducts) {
        foreach ($failed in $result.Response.data.failedProducts) {
            Write-Host "       Product $($failed.productId): $($failed.reason)" -ForegroundColor Gray
        }
    }
} else {
    Write-TestResult -TestName "Batch Update - Partial Failure" -Passed $false -Message "Batch update failed" -Details $result.Error
}

Write-TestHeader "ORDER CREATION TESTS"

$userHeaders = @{
    Authorization = "Bearer $UserToken"
}

Write-Host "`nGetting user addresses..." -ForegroundColor Yellow
$addressesResult = Invoke-ApiCall -Method "GET" -Endpoint "/addresses" -Headers $userHeaders
$testAddressId = $null

if ($addressesResult.Success -and $addressesResult.Response.code -eq 200) {
    $addresses = $addressesResult.Response.data
    if ($addresses.Count -gt 0) {
        $testAddressId = $addresses[0].id
        Write-Host "Using address ID: $testAddressId" -ForegroundColor Gray
    } else {
        Write-Host "No addresses found. Please run create_test_addresses.ps1 first." -ForegroundColor Red
    }
} else {
    Write-Host "Failed to get addresses" -ForegroundColor Red
}

Write-Host "`nTest Case 9: Create order - AUTO mode (sufficient stock)..." -ForegroundColor Yellow
if ($product1Id -and $testAddressId) {
    $orderBody = @{
        addressId = $testAddressId
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
if ($product2Id -and $testAddressId) {
    $orderBody = @{
        addressId = $testAddressId
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
if ($product3Id -and $testAddressId) {
    $orderBody = @{
        addressId = $testAddressId
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

Write-Host "`nTest Case 12: Batch update - empty product IDs..." -ForegroundColor Yellow
$batchBody3 = @{
    productIds = @()
    autoConfirmMode = "AUTO"
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody3

$passed = -not $result.Success -or $result.Response.code -ne 200
Write-TestResult -TestName "Batch Update - Empty Product IDs" -Passed $passed -Message "Expected to fail with empty list" -ResponseTime $result.ResponseTime

Write-Host "`nTest Case 13: Batch update - null autoConfirmMode..." -ForegroundColor Yellow
$batchBody4 = @{
    productIds = @($product1Id, $product2Id)
    autoConfirmMode = $null
}

$result = Invoke-ApiCall -Method "PATCH" -Endpoint "/merchant/products/auto-confirm-mode" -Headers $headers -Body $batchBody4

$passed = -not $result.Success -or $result.Response.code -ne 200
Write-TestResult -TestName "Batch Update - Null AutoConfirmMode" -Passed $passed -Message "Expected to fail with null mode" -ResponseTime $result.ResponseTime

Write-Host "`nTest Case 14: Update product - SMART mode without condition..." -ForegroundColor Yellow
if ($product1Id) {
    $updateFormData2 = @{
        title = "Test Product"
        category = "Health"
        price = "99.00"
        stock = "100"
        description = "Test description"
        status = "ON_SALE"
        autoConfirmMode = "SMART"
    }

    $result = Invoke-MultipartApiCall -Method "PUT" -Endpoint "/merchant/products/$product1Id" -Headers $headers -FormData $updateFormData2 -CoverImagePath $testCoverImage

    if ($result.Success -and $result.Response.code -eq 200) {
        $passed = $result.Response.data.autoConfirmMode -eq "SMART"
        Write-TestResult -TestName "Update Product - SMART Without Condition" -Passed $passed -Message "Product updated successfully" -ResponseTime $result.ResponseTime
    } else {
        Write-TestResult -TestName "Update Product - SMART Without Condition" -Passed $false -Message "Failed to update product" -Details $result.Error
    }
}

Write-Host "`nTest Case 15: AUTO mode - insufficient stock..." -ForegroundColor Yellow
if ($product1Id -and $testAddressId) {
    $orderBody2 = @{
        addressId = $testAddressId
        items = @(
            @{ productId = $product1Id; quantity = 1000 }
        )
        remark = "Test order"
    }

    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody2

    $passed = -not $result.Success -or $result.Response.code -eq 400
    Write-TestResult -TestName "Create Order - AUTO Insufficient Stock" -Passed $passed -Message "Expected to fail with insufficient stock" -ResponseTime $result.ResponseTime
}

Write-Host "`nTest Case 16: Mixed mode order..." -ForegroundColor Yellow
if ($product1Id -and $product2Id -and $testAddressId) {
    $orderBody3 = @{
        addressId = $testAddressId
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

Write-Host "`nTest Case 17: Batch update performance (100 products)..." -ForegroundColor Yellow
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
    
    Write-Host "`nResponse Time Statistics:" -ForegroundColor Cyan
    Write-Host "  Average: $([math]::Round($avgTime, 2))ms" -ForegroundColor White
    Write-Host "  Minimum: $minTime ms" -ForegroundColor White
    Write-Host "  Maximum: $maxTime ms" -ForegroundColor White
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = "d:\26bs\test_results_$timestamp.csv"

$TestResults | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "`nTest results exported to: $csvPath" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETED" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
