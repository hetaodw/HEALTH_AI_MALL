# Test Frontend Add Product API

Write-Host "=== Test Frontend Add Product API ===" -ForegroundColor Cyan

# 1. Merchant login
Write-Host "`n[1/3] Merchant login..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{
  "username": "testmerchant1",
  "password": "Test123456"
}'

if ($loginResponse.code -eq 200) {
  $token = $loginResponse.data.token
  Write-Host "Login successful" -ForegroundColor Green
  Write-Host "  Token: $($token.Substring(0, 50))..." -ForegroundColor Gray
} else {
  Write-Host "Login failed: $($loginResponse.msg)" -ForegroundColor Red
  exit 1
}

# 2. Prepare test image
Write-Host "`n[2/3] Preparing test data..." -ForegroundColor Yellow
$testImage = "test_cover.jpg"
if (-not (Test-Path $testImage)) {
  Write-Host "Creating test image..." -ForegroundColor Gray
  $bitmap = New-Object System.Drawing.Bitmap 200, 200
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.Clear([System.Drawing.Color]::White)
  $graphics.DrawString("Test", (New-Object System.Drawing.Font("Arial", 20)), [System.Drawing.Brushes]::Black, 50, 80)
  $bitmap.Save($testImage, [System.Drawing.Imaging.ImageFormat]::Jpeg)
  $graphics.Dispose()
  $bitmap.Dispose()
}

# 3. Call add product API with multipart/form-data (simulating frontend)
Write-Host "`n[3/3] Calling add product API..." -ForegroundColor Yellow

$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$bodyLines = @()
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"title`""
$bodyLines += ""
$bodyLines += "Test Product - Frontend API Call"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"category`""
$bodyLines += ""
$bodyLines += "HEALTH_PRODUCTS"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"description`""
$bodyLines += ""
$bodyLines += "Test product description"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"price`""
$bodyLines += ""
$bodyLines += "99.90"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"stock`""
$bodyLines += ""
$bodyLines += "100"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"status`""
$bodyLines += ""
$bodyLines += "ON_SALE"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"autoConfirmMode`""
$bodyLines += ""
$bodyLines += "MANUAL"
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"features`""
$bodyLines += ""
$bodyLines += '{\"brand\":\"Test Brand\",\"specification\":\"500mg/tablet\"}'
$bodyLines += "--$boundary"
$bodyLines += "Content-Disposition: form-data; name=`"coverImage`"; filename=`"$testImage`""
$bodyLines += "Content-Type: image/jpeg"
$bodyLines += ""

$imageBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $testImage))
$bodyString = $bodyLines -join $LF
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyString)
$bodyBytes += $imageBytes
$bodyBytes += [System.Text.Encoding]::UTF8.GetBytes("$LF--$boundary--$LF")

$headers = @{
  "Authorization" = "Bearer $token"
  "Content-Type" = "multipart/form-data; boundary=$boundary"
}

try {
  $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/merchant/products" -Method POST -Headers $headers -Body $bodyBytes -TimeoutSec 30
  
  Write-Host "`nResponse status code: $($response.StatusCode)" -ForegroundColor Cyan
  Write-Host "`nResponse content:" -ForegroundColor Yellow
  $responseContent = $response.Content | ConvertFrom-Json
  $responseContent | ConvertTo-Json -Depth 10
  
  if ($responseContent.code -eq 200) {
    Write-Host "`n[SUCCESS] API call successful!" -ForegroundColor Green
    Write-Host "  Product ID: $($responseContent.data.id)" -ForegroundColor Green
    Write-Host "  Product Title: $($responseContent.data.title)" -ForegroundColor Green
    
    # Verify if product is actually saved to database
    Write-Host "`nVerifying product is saved..." -ForegroundColor Yellow
    $verifyResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/products/$($responseContent.data.id)" -Method GET
    if ($verifyResponse.code -eq 200) {
      Write-Host "[SUCCESS] Product successfully saved to database" -ForegroundColor Green
    } else {
      Write-Host "[ERROR] Product not saved to database" -ForegroundColor Red
    }
  } else {
    Write-Host "`n[ERROR] API call failed!" -ForegroundColor Red
    Write-Host "  Error message: $($responseContent.msg)" -ForegroundColor Red
  }
} catch {
  Write-Host "`n[ERROR] Request failed!" -ForegroundColor Red
  Write-Host "  Error message: $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.Response) {
    $errorStream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorStream)
    $errorText = $reader.ReadToEnd()
    Write-Host "  Response content: $errorText" -ForegroundColor Red
  }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
