$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Test-MySqlConnection {
    Write-Host "Testing MySQL connection..." -ForegroundColor Yellow
    
    try {
        $null = docker exec mall-mysql mysql -u root -pTest123456 -e "SELECT 1" health_mall_system 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ MySQL connection successful" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ MySQL connection failed" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ MySQL connection failed: $_" -ForegroundColor Red
        return $false
    }
}

function Test-ApiConnection {
    Write-Host "Testing API connection..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/v1/auth/login" -Method POST -Body '{"username":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
            Write-Host "✅ API connection successful" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ API returned status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ API connection failed: $_" -ForegroundColor Red
        return $false
    }
}

function Invoke-DatabaseSeed {
    Write-Host "`nSeeding test data..." -ForegroundColor Yellow
    
    $seedScript = "d:\26bs\database\seed_test_products.sql"
    
    if (-not (Test-Path $seedScript)) {
        Write-Host "❌ Seed script not found: $seedScript" -ForegroundColor Red
        return $false
    }
    
    try {
        $result = Get-Content $seedScript | docker exec -i mall-mysql mysql -u root -pTest123456 health_mall_system 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Test data seeded successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Failed to seed test data" -ForegroundColor Red
            Write-Host "   Error: $result" -ForegroundColor Gray
            return $false
        }
    }
    catch {
        Write-Host "❌ Failed to seed test data: $_" -ForegroundColor Red
        return $false
    }
}

function Invoke-ApiTests {
    Write-Host "`nRunning API tests..." -ForegroundColor Yellow
    
    $testScript = "d:\26bs\scripts\api_test_fixed.ps1"
    
    if (-not (Test-Path $testScript)) {
        Write-Host "❌ Test script not found: $testScript" -ForegroundColor Red
        return $false
    }
    
    try {
        & powershell -ExecutionPolicy Bypass -File $testScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ API tests completed" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ API tests failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Failed to run API tests: $_" -ForegroundColor Red
        return $false
    }
}

function Invoke-DatabaseCleanup {
    Write-Host "`nCleaning up test data..." -ForegroundColor Yellow
    
    $cleanupScript = "d:\26bs\database\cleanup_test_products.sql"
    
    if (-not (Test-Path $cleanupScript)) {
        Write-Host "❌ Cleanup script not found: $cleanupScript" -ForegroundColor Red
        return $false
    }
    
    try {
        $result = Get-Content $cleanupScript | docker exec -i mall-mysql mysql -u root -pTest123456 health_mall_system 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Test data cleaned up successfully" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Failed to clean up test data" -ForegroundColor Red
            Write-Host "   Error: $result" -ForegroundColor Gray
            return $false
        }
    }
    catch {
        Write-Host "❌ Failed to clean up test data: $_" -ForegroundColor Red
        return $false
    }
}

function Show-Menu {
    Write-Host "`nSelect an option:" -ForegroundColor Cyan
    Write-Host "1. Run full test suite (seed + test + cleanup)" -ForegroundColor White
    Write-Host "2. Run test suite without cleanup" -ForegroundColor White
    Write-Host "3. Seed test data only" -ForegroundColor White
    Write-Host "4. Run API tests only" -ForegroundColor White
    Write-Host "5. Cleanup test data only" -ForegroundColor White
    Write-Host "6. Check dependencies only" -ForegroundColor White
    Write-Host "7. Exit" -ForegroundColor White
    Write-Host ""
}

function Show-Summary {
    param([bool]$AllPassed)
    
    Write-Section "TEST SUMMARY"
    
    if ($AllPassed) {
        Write-Host "✅ All dependencies are available and tests can proceed" -ForegroundColor Green
    } else {
        Write-Host "❌ Some dependencies are missing or not accessible" -ForegroundColor Red
        Write-Host "`nPlease ensure:" -ForegroundColor Yellow
        Write-Host "  1. MySQL is running on localhost:4000" -ForegroundColor White
        Write-Host "  2. Backend API is running on localhost:8080" -ForegroundColor White
        Write-Host "  3. Test accounts exist in the database" -ForegroundColor White
    }
}

Write-Section "PRODUCT AUTO-CONFIRMATION MODE - AUTOMATED TEST RUNNER"

Write-Host "This script will help you run the complete test suite for" -ForegroundColor White
Write-Host "the Product Auto-Confirmation Mode feature." -ForegroundColor White
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "  - MySQL running on localhost:4000" -ForegroundColor White
Write-Host "  - Backend API running on localhost:8080" -ForegroundColor White
Write-Host "  - Test accounts: testmerchant1/Test123456, testuser1/Test123456" -ForegroundColor White

Write-Section "CHECKING DEPENDENCIES"

$mysqlOk = Test-MySqlConnection
$apiOk = Test-ApiConnection

$allOk = $mysqlOk -and $apiOk

Show-Summary -AllPassed $allOk

if (-not $allOk) {
    Write-Host "`nWould you like to start the services? (y/n): " -ForegroundColor Yellow -NoNewline
    $startServices = Read-Host
    
    if ($startServices -eq 'y' -or $startServices -eq 'Y') {
        Write-Host "`nStarting services with docker-compose..." -ForegroundColor Yellow
        & docker-compose up -d
        
        Write-Host "Waiting for services to start..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        $mysqlOk = Test-MySqlConnection
        $apiOk = Test-ApiConnection
        
        Show-Summary -AllPassed ($mysqlOk -and $apiOk)
        
        if (-not ($mysqlOk -and $apiOk)) {
            Write-Host "`n❌ Services failed to start. Please check docker-compose logs." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "`n❌ Cannot proceed without required dependencies" -ForegroundColor Red
        exit 1
    }
}

Show-Menu
$choice = Read-Host "Enter your choice (1-7)"

switch ($choice) {
    '1' {
        Write-Section "RUNNING FULL TEST SUITE"
        
        $seeded = Invoke-DatabaseSeed
        if ($seeded) {
            $tested = Invoke-ApiTests
            if ($tested) {
                Write-Host "`nCleaning up test data..." -ForegroundColor Yellow
                Invoke-DatabaseCleanup
            }
        }
    }
    '2' {
        Write-Section "RUNNING TEST SUITE (NO CLEANUP)"
        
        $seeded = Invoke-DatabaseSeed
        if ($seeded) {
            Invoke-ApiTests
        }
    }
    '3' {
        Write-Section "SEEDING TEST DATA"
        Invoke-DatabaseSeed
    }
    '4' {
        Write-Section "RUNNING API TESTS"
        Invoke-ApiTests
    }
    '5' {
        Write-Section "CLEANING UP TEST DATA"
        Invoke-DatabaseCleanup
    }
    '6' {
        Write-Section "CHECKING DEPENDENCIES"
        Test-MySqlConnection
        Test-ApiConnection
    }
    '7' {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid choice. Please run the script again and select a valid option." -ForegroundColor Red
        exit 1
    }
}

Write-Section "COMPLETED"

Write-Host "Test execution completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review test results in test_results_*.csv" -ForegroundColor White
Write-Host "  2. Check API_TEST_REPORT.md for detailed analysis" -ForegroundColor White
Write-Host "  3. Review backend logs for any errors: docker-compose logs backend" -ForegroundColor White
Write-Host "  4. Run cleanup if needed: Get-Content database/cleanup_test_products.sql | docker exec -i mall-mysql mysql -u root -pTest123456 health_mall_system" -ForegroundColor White

Write-Host ""
Write-Host "For more information, see:" -ForegroundColor Cyan
Write-Host "  - scripts/README_TESTING.md" -ForegroundColor White
Write-Host "  - docs/PRODUCT_AUTO_CONFIRM_MODE_API_TEST.md" -ForegroundColor White
Write-Host "  - docs/API_DOCUMENTATION.md" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "THANK YOU" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
