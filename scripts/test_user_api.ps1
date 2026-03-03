$baseUrl = "http://localhost:8080/v1"
$testResults = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User API Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if user token exists
if (-not $global:userToken) {
    Write-Host "WARNING: User token not found. Please run auth tests first." -ForegroundColor Yellow
    Write-Host "Attempting to login with testuser1..." -ForegroundColor Yellow
    $loginBody = @{
        username = "testuser1"
        password = "Test123456"
    } | ConvertTo-Json
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
        $global:userToken = $response.data.token
        $global:userId = $response.data.userInfo.id
        Write-Host "Login successful. Token obtained." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to login. Cannot proceed with user API tests." -ForegroundColor Red
        exit 1
    }
}

$headers = @{
    "Authorization" = "Bearer $global:userToken"
}

# Test 1: Get User Profile
Write-Host "[Test 1] Get User Profile" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "PASS: Get user profile successful" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.username)" -ForegroundColor Gray
    Write-Host "  Email: $($response.data.email)" -ForegroundColor Gray
    Write-Host "  Phone: $($response.data.phone)" -ForegroundColor Gray
    Write-Host "  Role: $($response.data.role)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Get User Profile"
        Endpoint = "GET /v1/user/profile"
        Status = "PASS"
        Response = "User ID: $($response.data.id), Username: $($response.data.username)"
    }
} catch {
    Write-Host "FAIL: Get user profile failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get User Profile"
        Endpoint = "GET /v1/user/profile"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 2: Update User Profile (avatarUrl only)
Write-Host "[Test 2] Update User Profile (avatarUrl)" -ForegroundColor Yellow
$updateBody = @{
    avatarUrl = "http://example.com/new-avatar.jpg"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile/update" -Method Put -Headers $headers -Body $updateBody -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: Update user profile (avatarUrl) successful" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (avatarUrl)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "PASS"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "FAIL: Update user profile (avatarUrl) failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (avatarUrl)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 3: Update User Profile (remarks only)
Write-Host "[Test 3] Update User Profile (remarks)" -ForegroundColor Yellow
$updateBody2 = @{
    remarks = "Updated remarks for testing"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile/update" -Method Put -Headers $headers -Body $updateBody2 -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: Update user profile (remarks) successful" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (remarks)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "PASS"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "FAIL: Update user profile (remarks) failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (remarks)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 4: Update User Profile (both avatarUrl and remarks)
Write-Host "[Test 4] Update User Profile (both fields)" -ForegroundColor Yellow
$updateBody3 = @{
    avatarUrl = "http://example.com/updated-avatar.jpg"
    remarks = "Final updated remarks"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile/update" -Method Put -Headers $headers -Body $updateBody3 -ContentType "application/json" -ErrorAction Stop
    Write-Host "PASS: Update user profile (both fields) successful" -ForegroundColor Green
    Write-Host "  Response: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (both fields)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "PASS"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "FAIL: Update user profile (both fields) failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Update User Profile (both fields)"
        Endpoint = "PUT /v1/user/profile/update"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 5: Upload User Avatar (using .NET WebClient)
Write-Host "[Test 5] Upload User Avatar" -ForegroundColor Yellow
$testImagePath = "test_images\test_cover.jpg"

if (Test-Path $testImagePath) {
    $absolutePath = (Resolve-Path $testImagePath).Path
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("Authorization", "Bearer $global:userToken")
        $boundary = [System.Guid]::NewGuid().ToString()
        $webClient.Headers.Add("Content-Type", "multipart/form-data; boundary=$boundary")
        
        $fileBytes = [System.IO.File]::ReadAllBytes($absolutePath)
        $fileName = [System.IO.Path]::GetFileName($absolutePath)
        
        $body = "--$boundary`r`n"
        $body += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"`r`n"
        $body += "Content-Type: image/jpeg`r`n`r`n"
        $body += [System.Text.Encoding]::ASCII.GetString($fileBytes)
        $body += "`r`n--$boundary--`r`n"
        
        $responseBytes = $webClient.UploadData("$baseUrl/user/avatar/upload", "POST", [System.Text.Encoding]::ASCII.GetBytes($body))
        $responseString = [System.Text.Encoding]::ASCII.GetString($responseBytes)
        $responseData = $responseString | ConvertFrom-Json
        
        if ($responseData.code -eq 200) {
            Write-Host "PASS: Upload user avatar successful" -ForegroundColor Green
            Write-Host "  Avatar URL: $($responseData.data.avatarUrl)" -ForegroundColor Gray
            $testResults += [PSCustomObject]@{
                TestCase = "Upload User Avatar"
                Endpoint = "POST /v1/user/avatar/upload"
                Status = "PASS"
                Response = "Avatar URL: $($responseData.data.avatarUrl)"
            }
        } else {
            Write-Host "FAIL: Upload user avatar failed with code: $($responseData.code)" -ForegroundColor Red
            Write-Host "  Response: $responseString" -ForegroundColor Gray
            $testResults += [PSCustomObject]@{
                TestCase = "Upload User Avatar"
                Endpoint = "POST /v1/user/avatar/upload"
                Status = "FAIL"
                Response = "Code: $($responseData.code), Response: $responseString"
            }
        }
        $webClient.Dispose()
    } catch {
        Write-Host "FAIL: Upload user avatar failed: $($_.Exception.Message)" -ForegroundColor Red
        $testResults += [PSCustomObject]@{
            TestCase = "Upload User Avatar"
            Endpoint = "POST /v1/user/avatar/upload"
            Status = "FAIL"
            Response = $_.Exception.Message
        }
    }
} else {
    Write-Host "SKIP: Test image not found at $testImagePath" -ForegroundColor Yellow
    $testResults += [PSCustomObject]@{
        TestCase = "Upload User Avatar"
        Endpoint = "POST /v1/user/avatar/upload"
        Status = "SKIP"
        Response = "Test image not found"
    }
}
Write-Host ""

# Test 6: Get User Profile After Update
Write-Host "[Test 6] Get User Profile After Update" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "PASS: Get user profile after update successful" -ForegroundColor Green
    Write-Host "  User ID: $($response.data.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.data.username)" -ForegroundColor Gray
    Write-Host "  Avatar URL: $($response.data.avatarUrl)" -ForegroundColor Gray
    Write-Host "  Remarks: $($response.data.remarks)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Get User Profile After Update"
        Endpoint = "GET /v1/user/profile"
        Status = "PASS"
        Response = "Avatar: $($response.data.avatarUrl), Remarks: $($response.data.remarks)"
    }
} catch {
    Write-Host "FAIL: Get user profile after update failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Get User Profile After Update"
        Endpoint = "GET /v1/user/profile"
        Status = "FAIL"
        Response = $_.Exception.Message
    }
}
Write-Host ""

# Test 7: Access User Profile Without Token (should fail)
Write-Host "[Test 7] Access User Profile Without Token (should fail)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/user/profile" -Method Get -ErrorAction Stop
    Write-Host "FAIL: Access without token should have failed but succeeded" -ForegroundColor Red
    $testResults += [PSCustomObject]@{
        TestCase = "Access Without Token"
        Endpoint = "GET /v1/user/profile"
        Status = "FAIL (expected to fail but succeeded)"
        Response = ($response | ConvertTo-Json -Depth 3)
    }
} catch {
    Write-Host "PASS: Access without token correctly failed" -ForegroundColor Green
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
    $testResults += [PSCustomObject]@{
        TestCase = "Access Without Token"
        Endpoint = "GET /v1/user/profile"
        Status = "PASS (correctly failed)"
        Response = $_.Exception.Message
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passedCount = ($testResults | Where-Object { $_.Status -like "*PASS*" }).Count
$failedCount = ($testResults | Where-Object { $_.Status -like "*FAIL*" -and $_.Status -notlike "*correctly failed*" }).Count
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

$testResults | Export-Csv -Path "scripts\test_user_api_results.csv" -NoTypeInformation -Encoding UTF8
Write-Host "Test results saved to: scripts\test_user_api_results.csv" -ForegroundColor Gray
