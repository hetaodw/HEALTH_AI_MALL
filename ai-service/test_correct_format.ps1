$body = @{
    prompt = "<|im_start|>user
请为以下商品生成标签：
商品标题：无线蓝牙耳机 Pro
商品介绍：主动降噪，长续航30小时，Hi-Fi音质，兼容苹果安卓
<|im_end|>
<|im_start|>assistant
"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5001/api/generate-tags" -Method POST -ContentType "application/json" -Body $body
$response | ConvertTo-Json
