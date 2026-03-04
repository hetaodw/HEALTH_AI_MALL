# Simple test to verify the fix

Write-Host "=== Testing Add Product API ===" -ForegroundColor Cyan

# Login first
Write-Host "`n[1/2] Login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{
  "username": "testmerchant1",
  "password": "Test123456"
}'

if ($loginResponse.code -eq 200) {
  $token = $loginResponse.data.token
  Write-Host "Login successful" -ForegroundColor Green
} else {
  Write-Host "Login failed" -ForegroundColor Red
  exit 1
}

# Get merchant products to check if any exist
Write-Host "`n[2/2] Get merchant products..." -ForegroundColor Yellow
$headers = @{
  "Authorization" = "Bearer $token"
}

try {
  $productsResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/merchant/products" -Method GET -Headers $headers
  Write-Host "Product count: $($productsResponse.data.total)" -ForegroundColor Cyan
  
  if ($productsResponse.data.total -gt 0) {
    Write-Host "`nRecent products:" -ForegroundColor Yellow
    foreach ($product in $productsResponse.data.list) {
      Write-Host "  - ID: $($product.id), Title: $($product.title), Status: $($product.status)" -ForegroundColor Gray
    }
  } else {
    Write-Host "  No products found" -ForegroundColor Yellow
  }
} catch {
  Write-Host "Failed to get products: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
