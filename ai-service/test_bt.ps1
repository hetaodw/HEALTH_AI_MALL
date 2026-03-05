$body = @{
    prompt = "Please generate tags for: Wireless Bluetooth headphones, noise cancelling, 30hr battery"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body
$response | ConvertTo-Json
