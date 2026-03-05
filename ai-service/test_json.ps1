$body = @{
    prompt = "Generate tags in JSON array format for: Wireless Bluetooth headphones, noise cancelling, 30hr battery. Return like [""tag1"",""tag2""]"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body
$response | ConvertTo-Json
