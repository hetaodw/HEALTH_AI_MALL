$body = '{"username":"testuser1","password":"Test123456","email":"testuser1_duplicate@example.com","phone":"13800138999","role":"USER"}'
try { 
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/auth/register" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop 
    Write-Host "FAIL: Duplicate registration succeeded" 
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Content: $($response.Content)"
} catch { 
    Write-Host "PASS: Duplicate registration failed"
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Error: $($_.Exception.Message)"
}

$body2 = '{"username":"testuser1","password":"Test123456"}'
try { 
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/auth/login" -Method POST -Body $body2 -ContentType "application/json" -ErrorAction Stop 
    Write-Host "PASS: Correct password login succeeded"
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Content: $($response.Content)"
} catch { 
    Write-Host "FAIL: Correct password login failed"
    Write-Host "Error: $($_.Exception.Message)"
}

$body3 = '{"username":"testuser1","password":"WrongPassword123"}'
try { 
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/auth/login" -Method POST -Body $body3 -ContentType "application/json" -ErrorAction Stop 
    Write-Host "FAIL: Wrong password login succeeded"
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Content: $($response.Content)"
} catch { 
    Write-Host "PASS: Wrong password login failed"
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Error: $($_.Exception.Message)"
}
