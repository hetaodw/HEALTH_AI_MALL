$body = @{
    prompt = "Please generate 3-5 tags for this product. Tags should be concise and representative.

Product: Wireless Bluetooth Headphones
Description: Active noise cancellation, 30 hour battery life, Hi-Fi sound quality

Return JSON array format only, like: [""tag1"",""tag2"",""tag3""]"
} | ConvertTo-Json

Write-Host "Request Body:"
Write-Host $body
Write-Host ""

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body

Write-Host "Response:"
$response | ConvertTo-Json
