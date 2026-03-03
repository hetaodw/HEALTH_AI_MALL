$baseUrl = "http://localhost:8080/v1"
$testResults = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Product API Tests (User Side)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Get Product List (default)
Write-Host "[Test 1] Get Product List (default)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get product list successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First product ID: $($response.data.list[0].id)" -ForegroundColor Gray
        Write-Host "  First product title: $($response.data.list[0].title)" -ForegroundColor Gray
        $global:productId = $response.data.list[0].id
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Product List (default)"
        Endpoint = "GET /v1/products"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Get product list failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Product List (default)"
        Endpoint = "GET /v1/products"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 2: Get Product List (with pagination)
Write-Host "[Test 2] Get Product List (with pagination)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products?page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get product list with pagination successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Page: $($response.data.page)" -ForegroundColor Gray
    Write-Host "  Size: $($response.data.size)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Get Product List (with pagination)"
        Endpoint = "GET /v1/products?page=1&size=5"
        Status = "PASS"
        Response = "Total: $($response.data.total), Page: $($response.data.page), Size: $($response.data.size)"
    }
} catch {
    Write-Host "FAIL: Get product list with pagination failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Product List (with pagination)"
        Endpoint = "GET /v1/products?page=1&size=5"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 3: Get Hot Products
Write-Host "[Test 3] Get Hot Products" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products/hot?limit=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get hot products successful" -ForegroundColor Green
    Write-Host "  Products count: $($response.data.Count)" -ForegroundColor Gray
    if ($response.data.Count -gt 0) {
        Write-Host "  First hot product ID: $($response.data[0].id)" -ForegroundColor Gray
        Write-Host "  First hot product title: $($response.data[0].title)" -ForegroundColor Gray
        Write-Host "  First hot product isHot: $($response.data[0].isHot)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Hot Products"
        Endpoint = "GET /v1/products/hot?limit=5"
        Status = "PASS"
        Response = "Products count: $($response.data.Count)"
    }
} catch {
    Write-Host "FAIL: Get hot products failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Hot Products"
        Endpoint = "GET /v1/products/hot?limit=5"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 4: Search Products
Write-Host "[Test 4] Search Products" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products/search?keyword=维&page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Search products successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First result ID: $($response.data.list[0].id)" -ForegroundColor Gray
        Write-Host "  First result title: $($response.data.list[0].title)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Search Products"
        Endpoint = "GET /v1/products/search?keyword=维"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Search products failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Search Products"
        Endpoint = "GET /v1/products/search?keyword=维"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 5: Get Product Detail
Write-Host "[Test 5] Get Product Detail" -ForegroundColor Yellow
if ($global:productId) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/products/$($global:productId)" -Method Get -ErrorAction Stop
        Write-Host "PASS: Get product detail successful" -ForegroundColor Green
        Write-Host "  Product ID: $($response.data.id)" -ForegroundColor Gray
        Write-Host "  Title: $($response.data.title)" -ForegroundColor Gray
        Write-Host "  Category: $($response.data.category)" -ForegroundColor Gray
        Write-Host "  Price: $($response.data.price)" -ForegroundColor Gray
        Write-Host "  Stock: $($response.data.stock)" -ForegroundColor Gray
        Write-Host "  Status: $($response.data.status)" -ForegroundColor Gray
        Write-Host "  Merchant ID: $($response.data.merchantId)" -ForegroundColor Gray
        Write-Host "  Merchant Name: $($response.data.merchantName)" -ForegroundColor Gray
        Write-Host "  Average Rating: $($response.data.averageRating)" -ForegroundColor Gray
        Write-Host "  Review Count: $($response.data.reviewCount)" -ForegroundColor Gray
        Write-Host "  Detail Images count: $($response.data.detailImages.Count)" -ForegroundColor Gray
        $testResults += [PSCustomObject]@{
            TestCase = "Get Product Detail"
            Endpoint = "GET /v1/products/{id}"
            Status = "PASS"
            Response = "ID: $($response.data.id), Title: $($response.data.title), Price: $($response.data.price)"
        }
    } catch {
        Write-Host "FAIL: Get product detail failed: $($_.Exception.Message)" -ForegroundColor Red
        $testResults += [PSCustomObject]@{
            TestCase = "Get Product Detail"
            Endpoint = "GET /v1/products/{id}"
            Status = "FAIL"
            Response = $_.Exception.Message
        }
    }
} else {
    Write-Host "SKIP: No product ID available" -ForegroundColor Yellow
    $testResults += [PSCustomObject]@{
        TestCase = "Get Product Detail"
        Endpoint = "GET /v1/products/{id}"
        Status = "SKIP"
        Response = "No product ID available"
    }
}
Write-Host ""

# Test 6: Get Products by Category
Write-Host "[Test 6] Get Products by Category" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products/category/HEALTH_PRODUCTS?page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get products by category successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First product category: $($response.data.list[0].category)" -ForegroundColor Gray
        Write-Host "  First product title: $($response.data.list[0].title)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products by Category"
        Endpoint = "GET /v1/products/category/{category}"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Get products by category failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products by Category"
        Endpoint = "GET /v1/products/category/{category}"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 7: Get Products with Price Filter
Write-Host "[Test 7] Get Products with Price Filter" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products?minPrice=10&maxPrice=100&page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get products with price filter successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First product price: $($response.data.list[0].price)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Price Filter"
        Endpoint = "GET /v1/products?minPrice=10&maxPrice=100"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Get products with price filter failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Price Filter"
        Endpoint = "GET /v1/products?minPrice=10&maxPrice=100"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 8: Get Products with Sort
Write-Host "[Test 8] Get Products with Sort" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products?sortBy=price&sortOrder=asc&page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get products with sort successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First product price: $($response.data.list[0].price)" -ForegroundColor Gray
        Write-Host "  Last product price: $($response.data.list[$($response.data.list.Count-1)].price)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Sort"
        Endpoint = "GET /v1/products?sortBy=price&sortOrder=asc"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Get products with sort failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Sort"
        Endpoint = "GET /v1/products?sortBy=price&sortOrder=asc"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 9: Get Products with Hot Filter
Write-Host "[Test 9] Get Products with Hot Filter" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/products?isHot=true&page=1&size=5" -Method Get -ErrorAction Stop
    Write-Host "PASS: Get products with hot filter successful" -ForegroundColor Green
    Write-Host "  Total: $($response.data.total)" -ForegroundColor Gray
    Write-Host "  Products count: $($response.data.list.Count)" -ForegroundColor Gray
    if ($response.data.list.Count -gt 0) {
        Write-Host "  First product isHot: $($response.data.list[0].isHot)" -ForegroundColor Gray
    }
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Hot Filter"
        Endpoint = "GET /v1/products?isHot=true"
        Status = "PASS"
        Response = "Total: $($response.data.total), Products: $($response.data.list.Count)"
    }
} catch {
    Write-Host "FAIL: Get products with hot filter failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get Products with Hot Filter"
        Endpoint = "GET /v1/products?isHot=true"
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
$failedCount = ($testResults | Where-Object { $_.Status -like "*FAIL*" }).Count
$skipCount = ($testResults | Where-Object { $_.Status -like "*SKIP*" }).Count

Write-Host "Total Tests: $($testResults.Count)" -ForegroundColor White
Write-Host "Passed: $passedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor Red
Write-Host "Skipped: $skipCount" -ForegroundColor Yellow
Write-Host ""

Write-Host "Detailed Test Results:" -ForegroundColor Cyan
$testResults | Format-Table -AutoSize

Write-Host ""
Write-Host "Testing Complete!" -ForegroundColor Green

$testResults | Export-Csv -Path "scripts\test_product_api_results.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Test results saved to: scripts\test_product_api_results.csv" -ForegroundColor Gray
