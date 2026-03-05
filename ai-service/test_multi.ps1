$testCases = @(
    "Vitamin C supplement, 500mg, immunity boost",
    "Wireless Bluetooth headphones with active noise cancellation",
    "Organic green tea, pesticide free, mountain grown",
    "Kids sports shoes, breathable, comfortable",
    "Smart watch with heart rate monitor and GPS"
)

$apiUrl = "http://localhost:5001/api/generate-tags"

foreach ($desc in $testCases) {
    $prompt = "Generate 3-5 tags for this product: $desc"
    
    $body = @{
        prompt = $prompt
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body $body -TimeoutSec 60
        Write-Host "Product: $desc"
        Write-Host "Tags: $($response.tags -join ', ')"
        Write-Host ""
    } catch {
        Write-Host "FAILED: $desc - $($_.Exception.Message)"
    }
}
