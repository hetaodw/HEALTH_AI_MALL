$ErrorActionPreference = "Stop"

$USERNAME = "testmerchant1"
$PASSWORD = "Test123456"
$API_BASE = "http://localhost:8080/v1"
$TEST_IMAGE_PATH = "d:\26bs\test_images\test_cover.jpg"

Write-Host "=== API Test: Add Product ===" -ForegroundColor Cyan
Write-Host ""

$token = $null

try {
    Write-Host "[1/4] Merchant login..." -ForegroundColor Yellow
    $loginBody = @{
        username = $USERNAME
        password = $PASSWORD
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    if ($loginResponse.code -eq 200) {
        $token = $loginResponse.data.token
        Write-Host "Login successful" -ForegroundColor Green
        Write-Host "  User: $($loginResponse.data.userInfo.username)" -ForegroundColor Gray
        Write-Host "  Role: $($loginResponse.data.userInfo.role)" -ForegroundColor Gray
    } else {
        Write-Host "Login failed: $($loginResponse.msg)" -ForegroundColor Red
        exit 1
    }
    Write-Host ""

    Write-Host "[2/4] Preparing product data..." -ForegroundColor Yellow
    
    if (-not (Test-Path $TEST_IMAGE_PATH)) {
        Write-Host "Test image not found: $TEST_IMAGE_PATH" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Product data prepared" -ForegroundColor Green
    Write-Host "  Title: Test Product - Vitamin C" -ForegroundColor Gray
    Write-Host "  Category: HEALTH_PRODUCTS" -ForegroundColor Gray
    Write-Host "  Price: 99.90" -ForegroundColor Gray
    Write-Host "  Stock: 100" -ForegroundColor Gray
    Write-Host "  Image: test_cover.jpg" -ForegroundColor Gray
    Write-Host ""

    Write-Host "[3/4] Calling add product API (multipart/form-data)..." -ForegroundColor Yellow
    
    $fileBytes = [System.IO.File]::ReadAllBytes($TEST_IMAGE_PATH)
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    $bodyLines = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"title`"",
        "",
        "Test Product - Vitamin C",
        "--$boundary",
        "Content-Disposition: form-data; name=`"category`"",
        "",
        "HEALTH_PRODUCTS",
        "--$boundary",
        "Content-Disposition: form-data; name=`"price`"",
        "",
        "99.90",
        "--$boundary",
        "Content-Disposition: form-data; name=`"stock`"",
        "",
        "100",
        "--$boundary",
        "Content-Disposition: form-data; name=`"description`"",
        "",
        "Rich in Vitamin C, enhances immunity, antioxidant",
        "--$boundary",
        "Content-Disposition: form-data; name=`"features`"",
        "",
        "{""brand"":""Natural"",""specification"":""500mg/tablet"",""quantity"":""100 tablets/bottle""}",
        "--$boundary",
        "Content-Disposition: form-data; name=`"status`"",
        "",
        "ON_SALE",
        "--$boundary",
        "Content-Disposition: form-data; name=`"autoConfirmMode`"",
        "",
        "MANUAL",
        "--$boundary",
        "Content-Disposition: form-data; name=`"coverImage`"; filename=`"test_cover.jpg`"",
        "Content-Type: image/jpeg",
        "",
        [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($fileBytes),
        "--$boundary--",
        ""
    ) -join $LF

    $headers = @{
        "Authorization" = "Bearer $token"
    }

    $addProductResponse = Invoke-RestMethod -Uri "$API_BASE/merchant/products" -Method Post -Body $bodyLines -ContentType "multipart/form-data; boundary=$boundary" -Headers $headers
    
    if ($addProductResponse.code -eq 200) {
        $productId = $addProductResponse.data.id
        Write-Host "Product added successfully" -ForegroundColor Green
        Write-Host "  Product ID: $productId" -ForegroundColor Gray
        Write-Host "  Title: $($addProductResponse.data.title)" -ForegroundColor Gray
        Write-Host "  Price: $($addProductResponse.data.price)" -ForegroundColor Gray
        Write-Host "  Stock: $($addProductResponse.data.stock)" -ForegroundColor Gray
        Write-Host "  Status: $($addProductResponse.data.status)" -ForegroundColor Gray
        Write-Host "  Created at: $($addProductResponse.data.createdAt)" -ForegroundColor Gray
    } else {
        Write-Host "Product add failed: $($addProductResponse.msg)" -ForegroundColor Red
        exit 1
    }
    Write-Host ""

    Write-Host "[4/4] Verifying product..." -ForegroundColor Yellow
    $verifyResponse = Invoke-RestMethod -Uri "$API_BASE/products/$productId" -Method Get
    
    if ($verifyResponse.code -eq 200) {
        Write-Host "Product verification successful" -ForegroundColor Green
        Write-Host "  Product ID: $($verifyResponse.data.id)" -ForegroundColor Gray
        Write-Host "  Title: $($verifyResponse.data.title)" -ForegroundColor Gray
        Write-Host "  Category: $($verifyResponse.data.category)" -ForegroundColor Gray
        Write-Host "  Description: $($verifyResponse.data.description)" -ForegroundColor Gray
        Write-Host "  Cover URL: $($verifyResponse.data.coverUrl)" -ForegroundColor Gray
        Write-Host "  Price: $($verifyResponse.data.price)" -ForegroundColor Gray
        Write-Host "  Stock: $($verifyResponse.data.stock)" -ForegroundColor Gray
        Write-Host "  Status: $($verifyResponse.data.status)" -ForegroundColor Gray
    } else {
        Write-Host "Product verification failed: $($verifyResponse.msg)" -ForegroundColor Red
        exit 1
    }
    Write-Host ""

    Write-Host "=== Test Completed ===" -ForegroundColor Cyan
    Write-Host "All tests passed" -ForegroundColor Green
    Write-Host "Product ID: $productId" -ForegroundColor Cyan

} catch {
    Write-Host ""
    Write-Host "Test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error details: $($_.ScriptStackTrace)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Error response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}
