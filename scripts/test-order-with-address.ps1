$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/auth/login" -Method POST -ContentType "application/json" -Body '{"username":"testuser1","password":"Test123456"}'
$token = $loginResponse.data.token
Write-Host "Login success"
$headers = @{"Authorization" = "Bearer $token"}

$addressBody = @{
    receiverName = "张三"
    receiverPhone = "13800138001"
    province = "北京市"
    city = "北京市"
    district = "朝阳区"
    detailAddress = "测试地址123号"
    isDefault = $true
} | ConvertTo-Json -Depth 3

Write-Host "Creating address..."
$addressResponse = Invoke-RestMethod -Uri "http://localhost:8080/v1/addresses" -Method POST -Headers $headers -Body $addressBody -ContentType "application/json"
Write-Host "Address created: ID $($addressResponse.data.id)"

$addresses = Invoke-RestMethod -Uri "http://localhost:8080/v1/addresses" -Method GET -Headers $headers
Write-Host "Addresses: $($addresses.data.Count)"

$products = Invoke-RestMethod -Uri "http://localhost:8080/v1/products" -Method GET -Headers $headers
Write-Host "Products: $($products.data.Count)"

$body = @{
    addressId = $addresses.data[0].id
    items = @(@{productId = $products.data[0].id; quantity = 1})
    remark = "Test Order"
} | ConvertTo-Json -Depth 3

Write-Host "Creating order..."
$order = Invoke-RestMethod -Uri "http://localhost:8080/v1/orders" -Method POST -Headers $headers -Body $body -ContentType "application/json"
Write-Host "Order created: $($order.data.orderNo) - Status: $($order.data.status) - Amount: $($order.data.totalAmount)"
