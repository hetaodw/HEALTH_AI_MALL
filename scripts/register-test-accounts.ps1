$ErrorActionPreference = "Stop"

$baseUrl = "http://localhost:8080/v1"

$testAccounts = @(
    @{ username = "testuser1"; password = "Test123456"; email = "testuser1@example.com"; phone = "13800138001"; role = "USER" },
    @{ username = "testuser2"; password = "Test123456"; email = "testuser2@example.com"; phone = "13800138002"; role = "USER" },
    @{ username = "testuser3"; password = "Test123456"; email = "testuser3@example.com"; phone = "13800138003"; role = "USER" },
    @{ username = "testmerchant1"; password = "Test123456"; email = "testmerchant1@example.com"; phone = "13800138004"; role = "MERCHANT" },
    @{ username = "testmerchant2"; password = "Test123456"; email = "testmerchant2@example.com"; phone = "13800138005"; role = "MERCHANT" }
)

$registeredAccounts = @()

Write-Host "Starting test account registration..." -ForegroundColor Green

foreach ($account in $testAccounts) {
    try {
        $body = @{
            username = $account.username
            password = $account.password
            email = $account.email
            phone = $account.phone
            role = $account.role
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop

        if ($response.code -eq 200) {
            Write-Host "[OK] Success registered account: $($account.username) ($($account.role))" -ForegroundColor Green

            $registeredAccounts += [PSCustomObject]@{
                username = $account.username
                password = $account.password
                email = $account.email
                phone = $account.phone
                role = $account.role
            }
        } else {
            Write-Host "[FAIL] Registration failed: $($account.username) - $($response.msg)" -ForegroundColor Red
        }
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "409") {
            Write-Host "[WARN] Account already exists: $($account.username)" -ForegroundColor Yellow
            $registeredAccounts += [PSCustomObject]@{
                username = $account.username
                password = $account.password
                email = $account.email
                phone = $account.phone
                role = $account.role
            }
        } else {
            Write-Host "[FAIL] Registration failed: $($account.username) - $errorMsg" -ForegroundColor Red
        }
    }
}

Write-Host "`nRegistration complete! Total registered: $($registeredAccounts.Count) accounts" -ForegroundColor Cyan

Write-Host "`n=== Test Account List ===" -ForegroundColor Cyan
$registeredAccounts | Format-Table -AutoSize

$accountsJson = $registeredAccounts | ConvertTo-Json -Depth 3
$accountsJson | Out-File -FilePath "test_accounts.json" -Encoding UTF8
Write-Host "`nAccount info saved to test_accounts.json" -ForegroundColor Cyan

return $registeredAccounts
