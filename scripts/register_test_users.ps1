# Register test users via API

$users = @(
    @{
        username = "testuser1"
        password = "Test123456"
        email = "testuser1@example.com"
        phone = "13800138001"
        role = "USER"
    },
    @{
        username = "testuser2"
        password = "Test123456"
        email = "testuser2@example.com"
        phone = "13800138002"
        role = "USER"
    },
    @{
        username = "testuser3"
        password = "Test123456"
        email = "testuser3@example.com"
        phone = "13800138003"
        role = "USER"
    },
    @{
        username = "testmerchant1"
        password = "Test123456"
        email = "testmerchant1@example.com"
        phone = "13800138004"
        role = "MERCHANT"
    },
    @{
        username = "testmerchant2"
        password = "Test123456"
        email = "testmerchant2@example.com"
        phone = "13800138005"
        role = "MERCHANT"
    }
)

$headers = @{
    "Content-Type" = "application/json"
}

Write-Host "Starting user registration..."

foreach ($user in $users) {
    $userBody = $user | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/register" -Method Post -Body $userBody -Headers $headers
        if ($response.code -eq 200) {
            Write-Host "Registration successful: $($user.username) - Role: $($user.role)" -ForegroundColor Green
        } else {
            Write-Host "Registration failed: $($user.username) - Code: $($response.code) - Msg: $($response.msg)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Registration error: $($user.username) - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

Write-Host "`nAll user registrations completed!"
