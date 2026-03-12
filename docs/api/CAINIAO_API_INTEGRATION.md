# 菜鸟物流API集成文档

## 概述

Health Mall项目已集成菜鸟物流API，实现包裹物流信息的实时订阅和更新。通过菜鸟开放平台的LPC_PACK_PUB接口，系统可以自动接收包裹的物流状态更新。

## 集成架构

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   商家      │────────▶│  后端服务   │────────▶│  菜鸟API    │
│  (发货)     │         │  (订阅)     │         │  (推送)     │
└─────────────┘         └─────────────┘         └─────────────┘
                              │
                              ▼
                        ┌─────────────┐
                        │  数据库     │
                        │ (物流信息)  │
                        └─────────────┘
```

## 核心组件

### 1. 配置类 (CainiaoConfig)

**位置**: `com.healthmall.config.CainiaoConfig`

**配置参数**:
```yaml
cainiao:
  app-key: your-app-key              # 菜鸟应用Key
  app-secret: your-app-secret        # 菜鸟应用密钥
  partner-code: your-partner-code    # 合作伙伴编码
  from-code: your-from-code          # 调用方编码
  gateway-url: https://link.cainiao.com/gateway/link.do  # 正式环境
  sandbox-url: http://linkdaily.tbsandbox.com/gateway/link.do  # 沙箱环境
  sandbox-mode: true                 # 是否使用沙箱模式
```

### 2. 数据传输对象 (DTO)

#### CainiaoPackageData
**位置**: `com.healthmall.dto.cainiao.CainiaoPackageData`

**字段说明**:
- `cpCode`: 快递公司代码 (如: YTO, SF, STO)
- `logisticsStatus`: 包裹状态 (SIGN-已签收, PICKED-已揽收, IN_TRANSIT-运输中, EXCEPTION-异常)
- `subPhone`: 订阅手机号
- `mailNo`: 快递公司运单号
- `logisticsStatusDesc`: 包裹状态描述
- `lastLogisticDetail`: 最后一条物流详情
- `logisticsGmtModified`: 最后物流详情变更时间
- `city`: 当前城市
- `type`: 订阅手机号角色 (receive-收件人)
- `bizKey`: 日志key

#### CainiaoRequest
**位置**: `com.healthmall.dto.cainiao.CainiaoRequest`

**公共参数**:
- `msgType`: 消息类型 (LPC_PACK_PUB)
- `msgId`: 消息ID
- `fromCode`: 调用方编码
- `partnerCode`: 合作伙伴编码
- `dataDigest`: 请求签名 (MD5)
- `logisticsInterface`: 请求报文内容 (JSON)

#### CainiaoResponse
**位置**: `com.healthmall.dto.cainiao.CainiaoResponse`

**响应参数**:
- `success`: 是否成功
- `errorCode`: 错误码
- `errorMsg`: 错误原因

### 3. 服务类 (CainiaoService)

**位置**: `com.healthmall.service.CainiaoService`

**主要方法**:

#### subscribePackage
```java
public void subscribePackage(String mailNo, String subPhone)
```
- **功能**: 订阅包裹物流信息
- **参数**: 
  - `mailNo`: 运单号
  - `subPhone`: 订阅手机号
- **说明**: 创建电子面单时自动调用

#### handlePackageUpdate
```java
public CainiaoResponse handlePackageUpdate(CainiaoPackageData packageData)
```
- **功能**: 处理菜鸟推送的包裹更新
- **参数**: `packageData` - 包裹数据
- **返回**: `CainiaoResponse` - 处理结果
- **说明**: 更新物流状态和轨迹信息

### 4. 控制器 (CainiaoController)

**位置**: `com.healthmall.controller.CainiaoController`

#### 接收菜鸟回调
```java
POST /v1/cainiao/callback
```
- **功能**: 接收菜鸟推送的物流更新
- **请求体**: `CainiaoRequest`
- **响应**: `CainiaoResponse`
- **说明**: 菜鸟服务器调用此接口推送物流信息

#### 手动订阅包裹
```java
POST /v1/cainiao/subscribe?mailNo={mailNo}&subPhone={subPhone}
```
- **功能**: 手动订阅包裹物流信息
- **参数**:
  - `mailNo`: 运单号
  - `subPhone`: 订阅手机号
- **响应**: `ApiResponse<String>`
- **说明**: 用于测试或重新订阅

### 5. 数据库表更新

**表名**: `logistics_info`

**新增字段**:
- `cainiao_subscribed`: BOOLEAN - 是否已订阅菜鸟物流信息
- `cainiao_last_update`: DATETIME - 菜鸟最后更新时间

**迁移脚本**: `V2__add_cainiao_integration.sql`

## 集成流程

### 1. 创建电子面单流程

```
商家创建订单
    ↓
订单支付完成
    ↓
商家创建电子面单 (POST /v1/merchant/logistics/waybill)
    ↓
LogisticsService.createWaybill()
    ↓
自动调用 CainiaoService.subscribePackage()
    ↓
向菜鸟API发送订阅请求
    ↓
更新 logistics_info 表，设置 cainiao_subscribed = true
```

### 2. 接收物流更新流程

```
菜鸟服务器检测到物流状态变化
    ↓
菜鸟调用回调接口 (POST /v1/cainiao/callback)
    ↓
CainiaoController.handleCainiaoCallback()
    ↓
验证签名
    ↓
CainiaoService.handlePackageUpdate()
    ↓
更新 logistics_info 表:
  - 更新状态
  - 添加物流轨迹
  - 更新 cainiao_last_update
```

## 状态映射

| 菜鸟状态 | 系统状态 | 说明 |
|---------|---------|------|
| SIGN | DELIVERED | 已签收 |
| PICKED | PICKED | 已揽收 |
| IN_TRANSIT | IN_TRANSIT | 运输中 |
| EXCEPTION | EXCEPTION | 异常 |

## 签名算法

```java
String content = JSON.stringify(packageData);
String signContent = content + appSecret;
String dataDigest = MD5(signContent).toUpperCase();
```

## 测试

### 测试脚本

**位置**: `scripts/test_cainiao_integration.ps1`

**测试步骤**:
1. 商家登录
2. 获取现有订单
3. 创建电子面单（触发菜鸟订阅）
4. 查询物流信息
5. 模拟菜鸟回调
6. 验证物流更新

### 运行测试

```powershell
cd D:\25bs\HEALTH_AI_MALL
powershell -ExecutionPolicy Bypass -File scripts\test_cainiao_integration.ps1
```

## 配置说明

### 获取菜鸟凭证

1. 访问[菜鸟开放平台](https://open.cainiao.com)
2. 注册开发者账号
3. 创建应用，获取 appKey 和 appSecret
4. 配置回调URL: `https://your-domain.com/v1/cainiao/callback`
5. 获取 partnerCode 和 fromCode

### 环境配置

**开发/测试环境**:
```yaml
cainiao:
  sandbox-mode: true
  gateway-url: http://linkdaily.tbsandbox.com/gateway/link.do
```

**生产环境**:
```yaml
cainiao:
  sandbox-mode: false
  gateway-url: https://link.cainiao.com/gateway/link.do
```

## 注意事项

1. **签名验证**: 回调接口必须验证签名，防止伪造请求
2. **幂等性**: 同一个物流状态可能被推送多次，需要处理幂等性
3. **错误处理**: 菜鸟订阅失败不应影响电子面单创建
4. **日志记录**: 记录所有菜鸟交互日志，便于问题排查
5. **超时处理**: 菜鸟API调用设置合理的超时时间
6. **重试机制**: 订阅失败时实现重试机制

## 故障排查

### 问题1: 订阅失败

**可能原因**:
- 菜鸟凭证配置错误
- 网络连接问题
- 签名计算错误

**解决方法**:
1. 检查 application.yml 配置
2. 查看后端日志
3. 验证签名算法

### 问题2: 回调未收到

**可能原因**:
- 回调URL配置错误
- 防火墙阻止
- 菜鸟服务器无法访问

**解决方法**:
1. 确认回调URL可公网访问
2. 检查防火墙规则
3. 联系菜鸟技术支持

### 问题3: 物流状态未更新

**可能原因**:
- 运单号不匹配
- 状态映射错误
- 数据库更新失败

**解决方法**:
1. 检查运单号是否正确
2. 查看状态映射表
3. 检查数据库连接

## API参考

### 菜鸟官方文档

- **API文档**: https://open.cainiao.com/api-doc/detail?category=logistics&type=logistic_detail_tech&apiId=LPC_PACK_PUB
- **技术支持**: link@cainiao.com

### 系统API

#### 创建电子面单
```
POST /v1/merchant/logistics/waybill
Authorization: Bearer {token}
Content-Type: application/json

{
  "orderNo": "ORD20240311001",
  "logisticsCompany": "YTO"
}
```

#### 查询物流信息
```
GET /v1/merchant/logistics/{orderNo}
Authorization: Bearer {token}
```

#### 菜鸟回调
```
POST /v1/cainiao/callback
Content-Type: application/json

{
  "msgType": "LPC_PACK_PUB",
  "msgId": "unique-message-id",
  "fromCode": "your-from-code",
  "partnerCode": "your-partner-code",
  "dataDigest": "MD5-SIGNATURE",
  "logisticsInterface": "{...}"
}
```

## 更新日志

### v1.0 (2026-03-11)
- 初始版本
- 实现菜鸟API集成
- 支持包裹订阅和物流更新
- 添加测试脚本

---

**文档版本**: v1.0  
**最后更新**: 2026-03-11  
**维护者**: Health Mall Team
