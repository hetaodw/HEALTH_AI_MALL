$baseUrl = "http://localhost:8080/v1"

$userLoginBody = @{
    username = "testuser1"
    password = "Test123456"
} | ConvertTo-Json

$userLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $userLoginBody -ContentType "application/json"
$userToken = $userLoginResponse.data.token
Write-Host "User Token: $userToken"

$userHeaders = @{
    "Authorization" = "Bearer $userToken"
}

$response = Invoke-RestMethod -Uri "$baseUrl/merchant/orders/pending" -Method GET -Headers $userHeaders
Write-Host "Response: $($response | ConvertTo-Json -Depth 10)"