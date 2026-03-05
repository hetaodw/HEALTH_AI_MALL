# API Test Script
$results = @()

$testCases = @(
    @{
        title = "Product 1: Vitamin C"
        description = "Vitamin C supplement, 500mg, immunity boost"
    },
    @{
        title = "Product 2: Bluetooth Headphones"
        description = "Active noise cancellation, 30hr battery, Hi-Fi sound"
    },
    @{
        title = "Product 3: Organic Tea"
        description = "Organic black tea, mountain garden, pesticide free"
    },
    @{
        title = "Product 4: Kids Sports Shoes"
        description = "Breathable mesh, comfortable cushioning, non-slip"
    },
    @{
        title = "Product 5: Smart Watch"
        description = "Heart rate monitor, SpO2, GPS, 7-day battery, waterproof"
    }
)

$apiUrl = "http://localhost:5001/api/generate-tags"

foreach ($case in $testCases) {
    $prompt = "Please generate 3-5 tags for this product. Tags should be concise, accurate and representative.`n`nProduct Title: $($case.title)`nProduct Description: $($case.description)`n`nReturn JSON array format, e.g.: [""tag1"", ""tag2"", ""tag3""]"
    
    $body = @{
        prompt = $prompt
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body $body -TimeoutSec 60
        $results += @{
            title = $case.title
            description = $case.description
            tags = $response.tags
            status = "success"
        }
        Write-Host "SUCCESS: $($case.title) => $($response.tags -join ', ')"
    } catch {
        $results += @{
            title = $case.title
            description = $case.description
            error = $_.Exception.Message
            status = "fail"
        }
        Write-Host "FAILED: $($case.title) => $($_.Exception.Message)"
    }
}

Write-Host "`n========================================"
Write-Host "Test Results Summary"
Write-Host "========================================"

$results | ForEach-Object {
    if ($_.status -eq "success") {
        Write-Host "`nProduct: $($_.title)"
        Write-Host "Description: $($_.description)"
        Write-Host "Generated Tags: $($_.tags -join ', ')"
    } else {
        Write-Host "`nProduct: $($_.title) - FAILED"
        Write-Host "Error: $($_.error)"
    }
}
