@echo off
setlocal enabledelayedexpansion

set BASE_URL=http://localhost:8080/v1

echo === 并行处理性能测试 ===
echo.

echo 登录中...
curl -s -X POST "%BASE_URL%/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"testmerchant1\",\"password\":\"Test123456\"}" > login_response.json

for /f "tokens=2 delims=:," %%a in ('findstr /C:"\"token\"" login_response.json') do (
    set TOKEN=%%~a
    goto :token_found
)

:token_found
if "!TOKEN!"=="" (
    echo 登录失败
    exit /b 1
)

echo 登录成功
echo.

echo 测试批量生成标签（5个商品）...
powershell -Command "$startTime = (Get-Date).Ticks; $response = Invoke-RestMethod -Uri '%BASE_URL%/products/tags/batch/generate' -Method POST -Headers @{'Authorization'='Bearer !TOKEN!'; 'Content-Type'='application/json'} -Body '{\"productIds\":[1,2,3,4,5]}'; $endTime = (Get-Date).Ticks; $duration = [math]::Round(($endTime - $startTime) / 10000, 2); Write-Host ''; Write-Host '测试结果:'; Write-Host ('  响应时间: ' + $duration + 'ms'); Write-Host ('  成功: ' + $response.data.successCount); Write-Host ('  失败: ' + $response.data.failedCount); Write-Host ('  消息: ' + $response.message); if ($duration -lt 2000) { Write-Host ''; Write-Host '✅ 性能优化成功！响应时间从 17秒 降至 ' + $duration + 'ms' -ForegroundColor Green } elseif ($duration -lt 5000) { Write-Host ''; Write-Host '⚠️ 性能有所改善，但仍有优化空间。响应时间: ' + $duration + 'ms' -ForegroundColor Yellow } else { Write-Host ''; Write-Host '❌ 性能优化效果不佳。响应时间: ' + $duration + 'ms' -ForegroundColor Red }"

echo.
echo === 测试完成 ===

del login_response.json
