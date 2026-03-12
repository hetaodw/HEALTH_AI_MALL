# 新物流系统架构文档

## 概述

Health Mall项目已重构物流系统，采用统一的菜鸟API格式，支持多个物流提供商。系统使用策略模式，通过抽象接口实现不同物流提供商的无缝切换。

## 架构设计

### 设计模式

**策略模式 (Strategy Pattern)**: 通过`LogisticsProvider`接口定义统一的物流服务规范，不同的物流提供商实现该接口。

**依赖注入 (Dependency Injection)**: Spring自动扫描并注入所有`LogisticsProvider`实现类到`LogisticsProviderManager`。

### 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                   LogisticsController                      │
│                  (物流接口控制器)                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                 LogisticsService                          │
│                 (物流业务服务)                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              LogisticsProviderManager                      │
│              (物流提供商管理器)                            │
│  - 管理所有物流提供商                                   │
│  - 自动选择可用提供商                                     │
│  - 统一接口调用                                         │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         ▼           ▼           ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  TEST       │ │  CAINIAO    │ │  其他提供商   │
│  Provider   │ │  Service    │ │ (Future)    │
│ (测试物流)    │ │ (菜鸟物流)    │ │              │
└─────────────┘ └─────────────┘ └─────────────┘
```

## 核心组件

### 1. LogisticsProvider 接口

**位置**: `com.healthmall.service.logistics.LogisticsProvider`

**接口定义**:
```java
public interface LogisticsProvider {
    String getProviderCode();                    // 获取提供商代码
    String getProviderName();                    // 获取提供商名称
    void subscribePackage(String trackingNo, String phone);  // 订阅包裹
    CainiaoResponse handleCallback(CainiaoPackageData packageData);  // 处理回调
    boolean isAvailable();                      // 是否可用
}
```

### 2. LogisticsProviderManager

**位置**: `com.healthmall.service.LogisticsProviderManager`

**功能**:
- 管理所有物流提供商
- 根据提供商代码选择对应的提供商
- 自动选择可用的提供商
- 统一接口调用

**主要方法**:
```java
LogisticsProvider getProvider(String providerCode);           // 获取指定提供商
LogisticsProvider getAvailableProvider();                    // 获取可用提供商
void subscribePackage(String trackingNo, String phone, String providerCode);  // 订阅包裹
CainiaoResponse handleCallback(CainiaoPackageData packageData);  // 处理回调
List<String> getAvailableProviders();                       // 获取所有可用提供商
```

### 3. TestLogisticsProvider

**位置**: `com.healthmall.service.logistics.impl.TestLogisticsProvider`

**功能**:
- 模拟菜鸟API格式的测试物流提供商
- 用于开发和测试环境
- 支持完整的物流状态流转

**提供商代码**: `TEST`  
**提供商名称**: `测试物流公司`

### 4. CainiaoService

**位置**: `com.healthmall.service.CainiaoService`

**功能**:
- 实现菜鸟物流API集成
- 支持真实的菜鸟物流服务
- 需要配置菜鸟凭证

**提供商代码**: `CAINIAO`  
**提供商名称**: `菜鸟物流`

## 物流公司映射

| 物流公司枚举 | 提供商代码 | 说明 |
|--------------|-----------|------|
| TEST | TEST | 测试物流公司（模拟菜鸟API） |
| YTO | CAINIAO | 圆通速递（通过菜鸟） |
| SF | CAINIAO | 顺丰速运（通过菜鸟） |
| STO | CAINIAO | 申通快递（通过菜鸟） |
| ZTO | CAINIAO | 中通快递（通过菜鸟） |
| EMS | CAINIAO | EMS（通过菜鸟） |

## API接口

### 1. 获取可用物流提供商

```
GET /v1/cainiao/providers
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": ["测试物流公司", "菜鸟物流"]
}
```

### 2. 创建电子面单

```
POST /v1/merchant/logistics/waybill
Authorization: Bearer {token}
Content-Type: application/json

{
  "orderNo": "ORD20240311001",
  "logisticsCompany": "TEST"
}
```

**说明**: 
- `logisticsCompany` 为 `TEST` 时使用测试物流
- `logisticsCompany` 为其他值时使用菜鸟物流

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "orderNo": "ORD20240311001",
    "logisticsCompany": "TEST",
    "trackingNo": "TEST1710123456789",
    "status": "CREATED",
    "cainiaoSubscribed": true,
    "cainiaoLastUpdate": "2026-03-11T12:00:00"
  }
}
```

### 3. 查询物流信息

```
GET /v1/merchant/logistics/{orderNo}
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "orderNo": "ORD20240311001",
    "logisticsCompany": "TEST",
    "trackingNo": "TEST1710123456789",
    "status": "DELIVERED",
    "traceInfo": "[2026-03-11 12:00:00] 包裹已签收，签收人：本人\n[2026-03-11 10:00:00] 包裹正在运输中\n[2026-03-11 08:00:00] 快递员已揽收包裹",
    "cainiaoSubscribed": true,
    "cainiaoLastUpdate": "2026-03-11T12:00:00",
    "deliveredAt": "2026-03-11T12:00:00"
  }
}
```

### 4. 物流回调接口

```
POST /v1/cainiao/callback
Content-Type: application/json

{
  "msgType": "LPC_PACK_PUB",
  "msgId": "unique-message-id",
  "fromCode": "TEST",
  "partnerCode": "TEST",
  "dataDigest": "MD5-SIGNATURE",
  "logisticsInterface": "{...}"
}
```

**说明**: 
- `fromCode` 和 `cpCode` 用于识别物流提供商
- 系统自动路由到对应的提供商处理

### 5. 手动订阅包裹

```
POST /v1/cainiao/subscribe?mailNo={mailNo}&subPhone={subPhone}
```

**说明**: 用于测试或重新订阅包裹

## 数据流程

### 创建电子面单流程

```
1. 商家调用 POST /v1/merchant/logistics/waybill
   ↓
2. LogisticsService.createWaybill()
   ↓
3. 生成运单号 (applyTestWaybill/applyYtoWaybill...)
   ↓
4. 保存物流信息到数据库
   ↓
5. 调用 LogisticsProviderManager.subscribePackage()
   ↓
6. 根据物流公司选择提供商 (TEST → TestLogisticsProvider)
   ↓
7. 提供商执行订阅逻辑
   ↓
8. 更新数据库 cainiaoSubscribed = true
```

### 接收物流更新流程

```
1. 物流提供商推送更新到 POST /v1/cainiao/callback
   ↓
2. CainiaoController.handleCainiaoCallback()
   ↓
3. 验证签名
   ↓
4. 调用 LogisticsProviderManager.handleCallback()
   ↓
5. 根据 cpCode 选择提供商
   ↓
6. 提供商处理更新 (TestLogisticsProvider/CainiaoService)
   ↓
7. 更新物流状态和轨迹
   ↓
8. 保存到数据库
```

## 状态流转

### 物流状态

| 状态代码 | 状态名称 | 说明 |
|---------|---------|------|
| CREATED | 已创建 | 电子面单已创建，等待揽收 |
| PICKED | 已揽收 | 快递员已揽收包裹 |
| IN_TRANSIT | 运输中 | 包裹正在运输 |
| DELIVERED | 已签收 | 包裹已签收 |
| EXCEPTION | 异常 | 物流异常 |

### 状态流转图

```
CREATED → PICKED → IN_TRANSIT → DELIVERED
    ↓
EXCEPTION
```

## 配置

### application.yml

```yaml
cainiao:
  app-key: ${CAINIAO_APP_KEY:your-app-key}
  app-secret: ${CAINIAO_APP_SECRET:your-app-secret}
  partner-code: ${CAINIAO_PARTNER_CODE:your-partner-code}
  from-code: ${CAINIAO_FROM_CODE:your-from-code}
  gateway-url: ${CAINIAO_GATEWAY_URL:https://link.cainiao.com/gateway/link.do}
  sandbox-url: ${CAINIAO_SANDBOX_URL:http://linkdaily.tbsandbox.com/gateway/link.do}
  sandbox-mode: ${CAINIAO_SANDBOX_MODE:true}
```

### 环境变量

**开发/测试环境**:
- 使用 `TEST` 物流公司
- 不需要配置菜鸟凭证

**生产环境**:
- 使用真实物流公司（YTO, SF等）
- 需要配置菜鸟凭证

## 测试

### 测试脚本

**位置**: `scripts/test_new_logistics_system.ps1`

**测试内容**:
1. 商家登录
2. 获取可用物流提供商
3. 创建电子面单（使用TEST物流）
4. 查询物流信息
5. 模拟物流回调（PICKED状态）
6. 模拟物流回调（IN_TRANSIT状态）
7. 模拟物流回调（DELIVERED状态）
8. 验证最终物流信息

### 运行测试

```powershell
cd D:\25bs\HEALTH_AI_MALL
powershell -ExecutionPolicy Bypass -File scripts\test_new_logistics_system.ps1
```

## 扩展新的物流提供商

### 步骤

1. **创建新的Provider类**:
```java
@Service
public class NewLogisticsProvider implements LogisticsProvider {
    
    @Override
    public String getProviderCode() {
        return "NEW";
    }
    
    @Override
    public String getProviderName() {
        return "新物流公司";
    }
    
    @Override
    public void subscribePackage(String trackingNo, String phone) {
        // 实现订阅逻辑
    }
    
    @Override
    public CainiaoResponse handleCallback(CainiaoPackageData packageData) {
        // 实现回调处理逻辑
    }
    
    @Override
    public boolean isAvailable() {
        // 检查是否可用
        return true;
    }
}
```

2. **更新LogisticsInfo枚举**:
```java
public enum LogisticsCompany {
    TEST,
    NEW,  // 添加新物流公司
    SF,
    STO,
    YTO,
    ZTO,
    EMS
}
```

3. **更新LogisticsService**:
```java
private String convertToProviderCode(LogisticsInfo.LogisticsCompany company) {
    switch (company) {
        case NEW:
            return "NEW";
        // ... 其他case
    }
}

private String applyWaybillFromLogisticsCompany(Order order, LogisticsInfo.LogisticsCompany company) {
    switch (company) {
        case NEW:
            return applyNewWaybill(order);
        // ... 其他case
    }
}

private String applyNewWaybill(Order order) {
    return "NEW" + System.currentTimeMillis();
}
```

4. **重启应用**: Spring会自动扫描并注册新的Provider

## 优势

### 1. 统一接口
- 所有物流提供商使用相同的API格式
- 便于维护和扩展

### 2. 灵活切换
- 可以轻松切换不同的物流提供商
- 支持多提供商并存

### 3. 易于测试
- 提供测试物流提供商
- 不依赖真实物流服务

### 4. 可扩展性
- 新增物流提供商只需实现接口
- 不需要修改现有代码

### 5. 高可用性
- 自动选择可用的提供商
- 提高系统可靠性

## 注意事项

1. **签名验证**: 生产环境必须验证回调签名
2. **幂等性**: 同一状态可能被推送多次
3. **错误处理**: 物流订阅失败不应影响电子面单创建
4. **日志记录**: 记录所有物流交互日志
5. **超时处理**: 设置合理的超时时间
6. **重试机制**: 订阅失败时实现重试

## 故障排查

### 问题1: 物流提供商不可用

**可能原因**:
- Provider未正确注册
- isAvailable()返回false

**解决方法**:
1. 检查Provider类是否有@Service注解
2. 检查isAvailable()实现
3. 查看启动日志中的Provider列表

### 问题2: 回调未处理

**可能原因**:
- cpCode不匹配
- Provider未实现

**解决方法**:
1. 检查回调中的cpCode
2. 确认对应的Provider已实现
3. 查看错误日志

### 问题3: 物流状态未更新

**可能原因**:
- 状态映射错误
- 数据库更新失败

**解决方法**:
1. 检查状态映射逻辑
2. 查看数据库连接
3. 检查事务配置

## 更新日志

### v2.0 (2026-03-11)
- 重构物流系统架构
- 采用统一的菜鸟API格式
- 实现LogisticsProvider接口
- 添加TestLogisticsProvider测试提供商
- 创建LogisticsProviderManager管理器
- 支持多物流提供商
- 添加测试脚本

### v1.0 (2026-03-11)
- 初始版本
- 菜鸟API集成

---

**文档版本**: v2.0  
**最后更新**: 2026-03-11  
**维护者**: Health Mall Team
