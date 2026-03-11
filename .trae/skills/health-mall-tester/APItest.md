---
name: "health-mall-tester"
description: "Comprehensive testing skill for Health Mall project including API testing, code review, and functional testing. Invoke when testing APIs, reviewing code quality, or performing functional validation on Health Mall backend."
---

# Health Mall Tester

This skill provides comprehensive testing capabilities for the Health Mall e-commerce project, including API testing, code review, and functional validation.

## When to Use

Invoke this skill when:
- Testing Health Mall API endpoints
- Reviewing backend code for quality and best practices
- Performing functional testing on order, payment, logistics, or user management features
- Validating robustness mechanisms (idempotency, operation logs, state machine)
- Creating test scripts for the project
- Analyzing test results and generating reports

## Capabilities

### 1. API Testing

#### Test Categories
- **Authentication**: Login, register, logout
- **User Management**: Profile update, avatar upload, address management
- **Product Management**: CRUD operations, search, filtering
- **Order Management**: Create, pay, ship, cancel orders
- **Payment**: Payment processing, status tracking
- **Logistics**: Waybill creation, tracking info
- **Reviews**: Product reviews, ratings
- **Browsing History**: View tracking, history management

#### Test Approach
1. **Unit Testing**: Test individual API endpoints
2. **Integration Testing**: Test complete user flows
3. **Regression Testing**: Verify existing features after changes
4. **Load Testing**: Performance under concurrent requests

#### Test Scripts Location
- All test scripts: `scripts/` directory
- Test reports: `docs/test_reports/` directory

### 2. Code Review

#### Review Checklist
- **Code Quality**: Clean code principles, SOLID principles
- **Security**: SQL injection prevention, XSS protection, authentication
- **Performance**: Database queries, caching strategies, N+1 problem
- **Error Handling**: Proper exception handling, user-friendly messages
- **API Design**: RESTful principles, proper HTTP status codes
- **Documentation**: Code comments, API documentation

#### Key Files to Review
- Controllers: `backend/src/main/java/com/healthmall/controller/`
- Services: `backend/src/main/java/com/healthmall/service/`
- Repositories: `backend/src/main/java/com/healthmall/repository/`
- Entities: `backend/src/main/java/com/healthmall/entity/`
- DTOs: `backend/src/main/java/com/healthmall/dto/`

### 3. Functional Testing

#### Core Features
- **Order Flow**: Create → Confirm → Pay → Ship → Deliver → Complete
- **Payment Flow**: Payment processing, status updates, notifications
- **Logistics Flow**: Waybill creation, tracking, status updates
- **User Flow**: Registration → Login → Browse → Order → Review

#### Robustness Mechanisms
- **Idempotency**: Prevent duplicate operations using Redis
- **Operation Logging**: Track all user operations
- **State Machine**: Validate order status transitions
- **Risk Control**: High-risk order detection and approval

## Testing Workflow

### Phase 1: Preparation
1. Review API documentation in `docs/API_DOCUMENTATION.md`
2. Check existing test scripts in `scripts/` directory
3. Verify test environment is running (Docker containers)
4. Prepare test data (users, products, orders)

### Phase 2: Test Execution
1. Run individual API tests
2. Execute integration tests for complete flows
3. Verify robustness mechanisms
4. Collect test results and logs

### Phase 3: Code Review
1. Review controller code for API design
2. Review service code for business logic
3. Review repository code for database operations
4. Check for security vulnerabilities
5. Validate error handling

### Phase 4: Reporting
1. Generate test report in `docs/test_reports/`
2. Document bugs and issues found
3. Provide recommendations
4. Update test scripts for future use

## Test Script Templates

### Basic API Test Template
```powershell
# Test API Endpoint
$token = Get-Content "scripts\merchant_token.txt" -Raw

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/api/endpoint" -Method POST -Headers @{
        Authorization = "Bearer $token"
        "Content-Type" = "application/json"
    } -Body '{"key":"value"}'
    
    Write-Host "Test PASSED" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor Cyan
} catch {
    Write-Host "Test FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorStream)
        $errorText = $reader.ReadToEnd()
        Write-Host "Error Response: $errorText" -ForegroundColor Red
    }
}
```

### Code Review Template
```
File: [filename]
Location: [path]
Category: [Security/Performance/Code Quality/Design]

Issues Found:
1. [Issue description]
   - Severity: [Critical/High/Medium/Low]
   - Location: [line numbers]
   - Recommendation: [fix suggestion]

2. [Issue description]
   - Severity: [Critical/High/Medium/Low]
   - Location: [line numbers]
   - Recommendation: [fix suggestion]

Overall Assessment: [Pass/Needs Improvement/Fail]
```

## Common Test Scenarios

### Scenario 1: Complete Order Flow
1. User logs in
2. User browses products
3. User creates order
4. Merchant confirms order
5. User pays order
6. Merchant creates waybill
7. Merchant ships order
8. User receives order
9. User reviews product

### Scenario 2: Idempotency Testing
1. Create an order
2. Pay the order (first time)
3. Try to pay the same order again (second time)
4. Verify second payment is blocked

### Scenario 3: State Machine Testing
1. Create an order and ship it
2. Try to cancel the shipped order
3. Verify cancellation is blocked
4. Try invalid state transitions

### Scenario 4: Operation Log Testing
1. Perform various operations (login, create order, pay, etc.)
2. Query operation_logs table
3. Verify all operations are logged
4. Check log details (user, module, operation, timestamp)

## Testing Best Practices

1. **Always test with valid and invalid inputs**
2. **Verify error messages are user-friendly**
3. **Check HTTP status codes are appropriate**
4. **Test edge cases (empty inputs, null values, boundary values)**
5. **Verify database consistency after operations**
6. **Test concurrent operations for race conditions**
7. **Validate all response fields are present**
8. **Check for SQL injection and XSS vulnerabilities**
9. **Verify authentication and authorization**
10. **Test with different user roles (USER, MERCHANT, ADMIN)**

## Test Result Documentation

### Report Structure
```markdown
# [Test Name] Test Report

## Test Overview
- Test Date: [date]
- Test Environment: [environment details]
- Test Scope: [features tested]

## Test Results Summary
| Test Case | Status | Notes |
|-----------|--------|-------|
| [Case 1] | [Pass/Fail] | [notes] |
| [Case 2] | [Pass/Fail] | [notes] |

## Issues Found
1. [Issue description]
   - Severity: [Critical/High/Medium/Low]
   - Steps to Reproduce: [steps]
   - Expected Behavior: [expected]
   - Actual Behavior: [actual]

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## Conclusion
[Overall assessment]
```

## Quick Reference

### API Base URL
```
http://localhost:8080/v1
```

### Database Connection
```
Host: localhost:4000
Database: health_mall_system
User: root
Password: root123456
```

### Test Accounts
```
Merchant: testmerchant1 / Test123456
User: testuser1 / Test123456
Admin: admin / admin123
```

### Important Files
- API Documentation: `docs/API_DOCUMENTATION.md`
- Shipping API: `docs/SHIPPING_API_DOCUMENTATION.md`
- Robustness: `docs/ROBUSTNESS_MECHANISM.md`
- Test Scripts: `scripts/`
- Test Reports: `docs/test_reports/`

## Troubleshooting

### Common Issues

**Issue**: API returns 401 Unauthorized
- **Solution**: Check token is valid and not expired
- **Solution**: Verify Authorization header format

**Issue**: API returns 500 Internal Server Error
- **Solution**: Check backend logs: `docker logs mall-backend`
- **Solution**: Verify database connection

**Issue**: Test script fails with encoding errors
- **Solution**: Use UTF-8 encoding for file operations
- **Solution**: Check PowerShell execution policy

**Issue**: Database queries fail
- **Solution**: Verify MySQL container is running
- **Solution**: Check connection parameters

## Next Steps

After completing tests:
1. Review test results
2. Fix any issues found
3. Re-run tests to verify fixes
4. Update test scripts with new test cases
5. Document any new test scenarios
6. Share findings with development team

---

**Skill Version**: 1.0  
**Last Updated**: 2026-03-11  
**Project**: Health Mall E-commerce System
