$body = @{
    prompt = "Please generate tags for product: wireless bluetooth headphones with noise cancelling"
} | ConvertTo-Json

Write-Host "Request:"
$body

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body

Write-Host "Response:"
$response | ConvertTo-Json
