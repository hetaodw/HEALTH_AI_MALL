$ErrorActionPreference = "Stop"

$BaseUrl = "http://localhost:8080/v1"

function Write-Section {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

Write-Section "CREATING TEST ADDRESSES"

Write-Host "Logging in as testuser1..." -ForegroundColor Yellow

$loginBody = @{
    username = "testuser1"
    password = "Test123456"
}

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -Body ($loginBody | ConvertTo-Json -Depth 3) -ContentType "application/json"
    
    if ($loginResponse.code -ne 200) {
        Write-Host "Login failed" -ForegroundColor Red
        exit 1
    }
    
    $token = $loginResponse.data.token
    Write-Host "Login successful" -ForegroundColor Green
    Write-Host "User ID: $($loginResponse.data.userInfo.id)" -ForegroundColor Gray
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $testAddresses = @(
        @{
            receiverName = "Zhang San"
            receiverPhone = "13800138001"
            province = "Beijing"
            city = "Beijing"
            district = "Chaoyang"
            detailAddress = "No. 88 Jianguo Road"
            isDefault = $true
        },
        @{
            receiverName = "Li Si"
            receiverPhone = "13900139002"
            province = "Shanghai"
            city = "Shanghai"
            district = "Pudong New Area"
            detailAddress = "No. 1000 Lujiazui Ring Road"
            isDefault = $false
        },
        @{
            receiverName = "Wang Wu"
            receiverPhone = "13700137003"
            province = "Guangdong"
            city = "Guangzhou"
            district = "Tianhe"
            detailAddress = "No. 123 Tianhe Road"
            isDefault = $false
        }
    )
    
    Write-Host "`nCreating test addresses..." -ForegroundColor Yellow
    
    foreach ($address in $testAddresses) {
        $addressBody = $address | ConvertTo-Json -Depth 3
        
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl/addresses" -Method POST -Headers $headers -Body $addressBody -ContentType "application/json"
            
            if ($response.code -eq 200) {
                Write-Host "Address created: $($address.receiverName) - $($address.detailAddress)" -ForegroundColor Green
                Write-Host "Address ID: $($response.data.id)" -ForegroundColor Gray
            } else {
                Write-Host "Failed to create address: $($address.receiverName)" -ForegroundColor Red
                Write-Host "Error: $($response.msg)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "Error creating address: $($address.receiverName)" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nVerifying addresses..." -ForegroundColor Yellow
    
    $addressesResponse = Invoke-RestMethod -Uri "$BaseUrl/addresses" -Method GET -Headers $headers
    
    if ($addressesResponse.code -eq 200) {
        Write-Host "Total addresses: $($addressesResponse.data.Count)" -ForegroundColor Green
        
        foreach ($addr in $addressesResponse.data) {
            $defaultMarker = if ($addr.isDefault) { " (Default)" } else { "" }
            Write-Host "- $($addr.receiverName)$defaultMarker - $($addr.fullAddress)" -ForegroundColor White
        }
    } else {
        Write-Host "Failed to get addresses" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Section "COMPLETED"

Write-Host "Test addresses created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run API tests with:" -ForegroundColor Yellow
Write-Host ".\scripts\api_test_fixed.ps1" -ForegroundColor White
