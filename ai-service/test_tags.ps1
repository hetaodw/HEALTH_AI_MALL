$results = @()

$testCases = @(
    @{
        title = "天然维C片500mg"
        description = "富含维生素 C，增强免疫力，抗氧化"
    },
    @{
        title = "无线蓝牙耳机 Pro"
        description = "主动降噪，长续航30小时，Hi-Fi音质，兼容苹果安卓"
    },
    @{
        title = "有机红茶 100g"
        description = "来自高山茶园，天然有机，无农药残留，口感醇厚回甘"
    },
    @{
        title = "儿童运动鞋 32码"
        description = "透气网面，舒适减震，防滑耐磨，时尚百搭"
    },
    @{
        title = "智能手表 X3"
        description = "心率监测，血氧检测，GPS定位，7天续航，防水50米"
    }
)

$apiUrl = "http://localhost:5001/api/generate-tags"

foreach ($case in $testCases) {
    $prompt = "请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。`n`n商品标题：$($case.title)`n商品描述：$($case.description)`n`n请直接返回JSON数组格式的标签列表，例如：[""标签1"", ""标签2"", ""标签3""]"
    
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
        Write-Host "✅ $($case.title): $($response.tags -join ', ')"
    } catch {
        $results += @{
            title = $case.title
            description = $case.description
            error = $_.Exception.Message
            status = "fail"
        }
        Write-Host "❌ $($case.title): $($_.Exception.Message)"
    }
}

Write-Host "`n========== 测试结果汇总 =========="
$results | ForEach-Object {
    if ($_.status -eq "success") {
        Write-Host "`n商品: $($_.title)"
        Write-Host "描述: $($_.description)"
        Write-Host "生成标签: $($_.tags -join ', ')"
    } else {
        Write-Host "`n商品: $($_.title) - 失败"
        Write-Host "错误: $($_.error)"
    }
}
