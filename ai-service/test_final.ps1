$testCases = @(
    "Generate tags in JSON array format for: Vitamin C 500mg supplement, immunity boost, antioxidant",
    "Generate tags in JSON array format for: Wireless Bluetooth headphones, noise cancelling, 30hr battery, Hi-Fi sound",
    "Generate tags in JSON array format for: Organic green tea, pesticide free, mountain grown",
    "Generate tags in JSON array format for: Kids sports shoes, breathable mesh, comfortable cushioning",
    "Generate tags in JSON array format for: Smart watch, heart rate monitor, SpO2, GPS, waterproof"
)

$apiUrl = "http://localhost:5001/api/generate-tags"

foreach ($prompt in $testCases) {
    $body = @{
        prompt = $prompt
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body $body -TimeoutSec 60
        Write-Host "Input: $($prompt -replace 'Generate tags in JSON array format for: ', '')"
        Write-Host "Tags: $($response.tags -join ', ')"
        Write-Host ""
    } catch {
        Write-Host "FAILED: $($_.Exception.Message)"
    }
}
