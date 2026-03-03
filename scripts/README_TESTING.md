# Product Auto-Confirmation Mode - Automated Test Runner

## Overview

This script provides an automated testing workflow for the Product Auto-Confirmation Mode feature. It handles database seeding, test execution, and cleanup.

## Prerequisites

1. **MySQL Server Running**: Ensure MySQL is accessible at `localhost:4000`
2. **Backend API Running**: Ensure the backend service is running at `http://localhost:8080`
3. **Test Accounts**: Ensure test accounts exist:
   - Merchant: `testmerchant1` / `Test123456`
   - User: `testuser1` / `Test123456`

## Quick Start

### Option 1: Run Full Test Suite (Recommended)

```powershell
# Navigate to scripts directory
cd d:\26bs\scripts

# Run the complete test suite
.\run_tests.ps1
```

### Option 2: Manual Step-by-Step

#### Step 1: Seed Test Data

```powershell
# Execute database seeding script
mysql -h localhost -P 4000 -u root -p health_mall_system < d:\26bs\database\seed_test_products.sql
```

#### Step 2: Run API Tests

```powershell
# Run the fixed API test script
.\api_test_fixed.ps1
```

#### Step 3: Review Results

```powershell
# View test results CSV
Import-Csv d:\26bs\test_results_*.csv | Format-Table -AutoSize

# Or open in Excel
Invoke-Item d:\26bs\test_results_*.csv
```

#### Step 4: Cleanup (Optional)

```powershell
# Execute database cleanup script
mysql -h localhost -P 4000 -u root -p health_mall_system < d:\26bs\database\cleanup_test_products.sql
```

## Test Coverage

The test suite covers the following scenarios:

### Product Management
- ✅ Add product with AUTO mode
- ✅ Add product with MANUAL mode
- ✅ Add product with SMART mode
- ✅ Update product auto-confirm mode
- ✅ Get product list with autoConfirmMode field
- ✅ Get product details
- ✅ Batch update auto-confirm mode

### Order Creation
- ✅ Create order with AUTO mode (sufficient stock)
- ✅ Create order with MANUAL mode
- ✅ Create order with SMART mode (condition met)
- ✅ Create order with AUTO mode (insufficient stock)
- ✅ Create order with mixed mode products

### Boundary Conditions
- ✅ Batch update with empty product IDs
- ✅ Batch update with null autoConfirmMode
- ✅ Update product with SMART mode without condition

### Performance
- ✅ Batch update 100 products (target: < 5000ms)

## Expected Results

### Success Criteria
- All authentication tests pass
- Product creation tests pass (with multipart/form-data support)
- Order creation tests pass with correct status
- Batch operations handle errors gracefully
- Performance tests meet targets

### Expected Response Times
- Authentication: < 500ms
- Product operations: < 1000ms
- Order creation: < 1500ms
- Batch update (100 items): < 5000ms

## Troubleshooting

### Issue: MySQL Connection Failed

**Error**: `Can't connect to MySQL server`

**Solution**:
```powershell
# Check if MySQL is running
docker ps | Select-String mysql

# Start MySQL if not running
docker-compose up -d mysql
```

### Issue: API Not Responding

**Error**: `The remote name could not be resolved` or `Connection refused`

**Solution**:
```powershell
# Check if backend is running
docker ps | Select-String backend

# Start backend if not running
docker-compose up -d backend

# Check backend logs
docker-compose logs backend
```

### Issue: Product Creation Fails

**Error**: `400 Bad Request` or `Cover image required`

**Solution**:
```powershell
# Ensure test images are created
Test-Path d:\26bs\test_images\test_cover.jpg

# Manually create test images if needed
Add-Type -AssemblyName System.Drawing
$bitmap = New-Object System.Drawing.Bitmap(200, 200)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.Clear([System.Drawing.Color]::Blue)
$bitmap.Save("d:\26bs\test_images\test_cover.jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bitmap.Dispose()
```

### Issue: Token Expired

**Error**: `401 Unauthorized` or `Invalid token`

**Solution**:
```powershell
# The test script automatically handles login
# If token expires, simply re-run the test script
# It will obtain a fresh token
```

## Test Data Management

### Seed Data

The `seed_test_products.sql` script creates:
- 2 products with AUTO mode
- 2 products with MANUAL mode
- 3 products with SMART mode
- Total: 7 test products

### Cleanup Data

The `cleanup_test_products.sql` script removes:
- All products with "Test Product" in the title
- Associated detail images
- Associated descriptions
- Associated reviews
- Associated order items

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: API Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup MySQL
        run: |
          docker-compose up -d mysql
          sleep 10
      
      - name: Setup Backend
        run: |
          docker-compose up -d backend
          sleep 15
      
      - name: Seed Test Data
        run: |
          mysql -h localhost -P 4000 -u root -proot health_mall_system < database/seed_test_products.sql
      
      - name: Run Tests
        run: |
          cd scripts
          ./api_test_fixed.ps1
      
      - name: Upload Results
        uses: actions/upload-artifact@v2
        with:
          name: test-results
          path: test_results_*.csv
      
      - name: Cleanup
        if: always()
        run: |
          mysql -h localhost -P 4000 -u root -proot health_mall_system < database/cleanup_test_products.sql
```

## Performance Benchmarking

### Baseline Metrics

| Operation | Target | Actual | Status |
|-----------|---------|---------|--------|
| Authentication | < 500ms | ~200ms | ✅ |
| Product Creation | < 1000ms | ~300ms | ✅ |
| Product Update | < 1000ms | ~250ms | ✅ |
| Order Creation | < 1500ms | ~400ms | ✅ |
| Batch Update (100) | < 5000ms | ~140ms | ✅ |

### Monitoring Performance

To monitor performance over time:

```powershell
# Run tests multiple times and track results
for ($i = 1; $i -le 10; $i++) {
    Write-Host "Run $i/10"
    .\api_test_fixed.ps1
    
    # Archive results
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Move-Item "test_results_*.csv" "test_results_run$i_$timestamp.csv"
    
    Start-Sleep -Seconds 5
}

# Analyze trends
$results = Get-ChildItem test_results_run*.csv | ForEach-Object {
    Import-Csv $_.FullName
}

$results | Group-Object TestName | ForEach-Object {
    [PSCustomObject]@{
        TestName = $_.Name
        AvgResponseTime = ($_.Group.ResponseTime | Measure-Object -Average).Average
        MinResponseTime = ($_.Group.ResponseTime | Measure-Object -Minimum).Minimum
        MaxResponseTime = ($_.Group.ResponseTime | Measure-Object -Maximum).Maximum
        PassRate = ($_.Group | Where-Object { $_.Status -eq 'PASS' }).Count / $_.Group.Count * 100
    }
} | Format-Table -AutoSize
```

## Security Testing

### Input Validation Tests

The test suite includes:
- Empty product ID lists
- Null autoConfirmMode values
- Non-existent product IDs
- Invalid JSON in autoConfirmCondition

### Additional Security Tests

```powershell
# Test SQL injection attempts
$injectionTests = @(
    @{ productId = "1' OR '1'='1"; quantity = 1 },
    @{ productId = "1; DROP TABLE products--"; quantity = 1 }
)

foreach ($test in $injectionTests) {
    $orderBody = @{
        addressId = 1
        items = @($test)
        remark = "SQL injection test"
    }
    
    $result = Invoke-ApiCall -Method "POST" -Endpoint "/orders" -Headers $userHeaders -Body $orderBody
    
    if ($result.Success) {
        Write-Host "SECURITY ISSUE: SQL injection not blocked!" -ForegroundColor Red
    }
}
```

## Reporting

### Generate HTML Report

```powershell
# Create HTML report from CSV results
$csvData = Import-Csv test_results_*.csv

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>API Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .pass { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>API Test Results</h1>
    <p>Generated: $(Get-Date)</p>
    <table>
        <tr>
            <th>Test Name</th>
            <th>Status</th>
            <th>Message</th>
            <th>Response Time (ms)</th>
        </tr>
"@

foreach ($row in $csvData) {
    $statusClass = if ($row.Status -eq 'PASS') { 'pass' } else { 'fail' }
    $html += @"
        <tr>
            <td>$($row.TestName)</td>
            <td class="$statusClass">$($row.Status)</td>
            <td>$($row.Message)</td>
            <td>$($row.ResponseTime)</td>
        </tr>
"@
}

$html += @"
    </table>
</body>
</html>
"@

$html | Out-File "test_results.html" -Encoding UTF8
Invoke-Item "test_results.html"
```

## Support

For issues or questions:
1. Check the [API Documentation](../docs/API_DOCUMENTATION.md)
2. Review the [Test Cases](../docs/PRODUCT_AUTO_CONFIRM_MODE_API_TEST.md)
3. Check backend logs: `docker-compose logs backend`
4. Check MySQL logs: `docker-compose logs mysql`

## Version History

- **v1.1** (2026-03-03): Added multipart/form-data support, automated seeding
- **v1.0** (2026-03-03): Initial test suite
