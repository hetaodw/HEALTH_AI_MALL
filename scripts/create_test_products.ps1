# Create test products via API after login

# 1. Login to get token
$loginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.data.token
    
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host "Token: $($token.Substring(0, 50))..." -ForegroundColor Yellow
    
    # 2. Create test products
    $products = @(
        @{
            title = "Vitamin C"
            category = "HEALTH_PRODUCTS"
            description = "Vitamin C supplement"
            coverUrl = "http://localhost:8080/v1/static/test/test_cover.jpg"
            features = "{}"
            descriptionContent = "Natural Vitamin C from acerola cherry"
            price = 59.9
            stock = 100
            status = "ON_SALE"
            autoConfirmMode = "MANUAL"
        },
        @{
            title = "Fish Oil"
            category = "HEALTH_PRODUCTS"
            description = "Omega-3 fatty acids"
            coverUrl = "http://localhost:8080/v1/static/test/test_cover.jpg"
            features = "{}"
            descriptionContent = "Deep sea fish oil rich in Omega-3"
            price = 128.0
            stock = 80
            status = "ON_SALE"
            autoConfirmMode = "MANUAL"
        },
        @{
            title = "Calcium Tablets"
            category = "HEALTH_PRODUCTS"
            description = "Calcium supplement"
            coverUrl = "http://localhost:8080/v1/static/test/test_cover.jpg"
            features = "{}"
            descriptionContent = "Calcium with Vitamin D3 for better absorption"
            price = 89.5
            stock = 120
            status = "ON_SALE"
            autoConfirmMode = "MANUAL"
        },
        @{
            title = "Probiotics"
            category = "HEALTH_PRODUCTS"
            description = "Gut health support"
            coverUrl = "http://localhost:8080/v1/static/test/test_cover.jpg"
            features = "{}"
            descriptionContent = "Multiple probiotic strains for gut balance"
            price = 199.0
            stock = 60
            status = "ON_SALE"
            autoConfirmMode = "MANUAL"
        },
        @{
            title = "Collagen"
            category = "HEALTH_PRODUCTS"
            description = "Skin health supplement"
            coverUrl = "http://localhost:8080/v1/static/test/test_cover.jpg"
            features = "{}"
            descriptionContent = "Collagen peptides for skin elasticity"
            price = 258.0
            stock = 90
            status = "ON_SALE"
            autoConfirmMode = "MANUAL"
        }
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "`nCreating products..." -ForegroundColor Cyan
    
    foreach ($product in $products) {
        $productBody = $product | ConvertTo-Json
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/merchant/products" -Method Post -Body $productBody -Headers $headers
            if ($response.code -eq 200) {
                Write-Host "Product created: $($product.title) - ID: $($response.data.id)" -ForegroundColor Green
            } else {
                Write-Host "Product creation failed: $($product.title) - Code: $($response.code) - Msg: $($response.msg)" -ForegroundColor Red
            }
        } catch {
            Write-Host "Product creation error: $($product.title) - Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 300
    }
    
    Write-Host "`nAll products created successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
}
