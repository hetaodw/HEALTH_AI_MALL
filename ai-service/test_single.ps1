$body = @{
    prompt = "Generate 3 tags for wireless headphones with Bluetooth and noise cancelling. Return JSON array format like: [""tag1"",""tag2"",""tag3""]"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body
$response | ConvertTo-Json
