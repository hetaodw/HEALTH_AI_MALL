$testCases = @(
    "商品标题：天然维C片500mg`n商品描述：富含维生素 C，增强免疫力，抗氧化",
    "商品标题：无线蓝牙耳机 Pro`n商品描述：主动降噪，长续航30小时，Hi-Fi音质",
    "商品标题：有机红茶 100g`n商品描述：来自高山茶园，天然有机，无农药残留",
    "商品标题：儿童运动鞋 32码`n商品描述：透气网面，舒适减震，防滑耐磨",
    "商品标题：智能手表 X3`n商品描述：心率监测，血氧检测，GPS定位，7天续航"
)

$apiUrl = "http://localhost:5001/api/generate-tags"

foreach ($desc in $testCases) {
    $prompt = "请为以下商品生成3-5个标签，标签要简洁、准确：`n$desc"
    
    $body = @{
        prompt = $prompt
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body $body -TimeoutSec 60
        Write-Host "Product: $($desc -replace '`n', ' | ')"
        Write-Host "Tags: $($response.tags -join ', ')"
        Write-Host ""
    } catch {
        Write-Host "FAILED: $($_.Exception.Message)"
    }
}
