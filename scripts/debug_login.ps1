# Debug login response

$loginBody = @{
    username = "testmerchant1"
    password = "Test123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    
    Write-Host "Full response:" -ForegroundColor Cyan
    Write-Host ($loginResponse | ConvertTo-Json -Depth 10) -ForegroundColor Yellow
    
    Write-Host "`nCode: $($loginResponse.code)" -ForegroundColor Green
    Write-Host "Msg: $($loginResponse.msg)" -ForegroundColor Green
    Write-Host "Data type: $($loginResponse.data.GetType().Name)" -ForegroundColor Cyan
    
    if ($loginResponse.data) {
        Write-Host "Data: $($loginResponse.data | ConvertTo-Json -Depth 5)" -ForegroundColor Yellow
        if ($loginResponse.data.token) {
            Write-Host "Token found: $($loginResponse.data.token.Substring(0, 50))..." -ForegroundColor Green
        } else {
            Write-Host "Token is null or missing" -ForegroundColor Red
        }
    } else {
        Write-Host "Data is null" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Error Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}
