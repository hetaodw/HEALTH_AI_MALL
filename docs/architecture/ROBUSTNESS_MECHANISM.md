# Health Mall 健壮性保障机制文档

## 目录

- [接口幂等性保障](#接口幂等性保障)
  - [1. @Idempotent 注解](#1-idempotent-注解)
  - [2. IdempotentAspect 切面](#2-idempotentaspect-切面)
  - [3. 使用示例](#3-使用示例)
- [操作日志记录](#操作日志记录)
  - [4. @OperationLog 注解](#4-operationlog-注解)
  - [5. OperationLog 实体](#5-operationlog-实体)
  - [6. OperationLogRepository](#6-operationlogrepository)
  - [7. OperationLogAspect 切面](#7-operationlogaspect-切面)
  - [8. 使用示例](#8-使用示例)
- [状态机配置](#状态机配置)
  - [9. OrderStateMachineConfig](#9-orderstatemachineconfig)
  - [10. 订单状态转换规则](#10-订单状态转换规则)
  - [11. 使用示例](#11-使用示例)
- [配置文件更新](#配置文件更新)
  - [12. pom.xml](#12-pomxml)
  - [13. application.yml](#13-applicationyml)

---

## 接口幂等性保障

### 1. @Idempotent 注解

**文件路径**: `com.healthmall.annotation.Idempotent`

**作用**: 标记需要幂等性保障的接口方法

**参数说明**:
| 参数 | 类型 | 默认值 | 说明 |
|------|------|----------|------|
| key | string | "" | 幂等性键，为空时自动生成 |
| expireSeconds | long | 300 | 过期时间（秒） |
| message | string | "重复请求，请勿重复提交" | 重复请求时的提示信息 |

**使用场景**:
- 创建订单：防止用户重复提交订单
- 支付订单：防止用户重复支付
- 发货操作：防止商家重复发货

---

### 2. IdempotentAspect 切面

**文件路径**: `com.healthmall.aspect.IdempotentAspect`

**实现原理**:
1. 基于Redis实现分布式锁
2. 使用`setIfAbsent`原子操作确保唯一性
3. 方法执行成功后保留锁，失败时删除锁
4. 支持自定义幂等性键和过期时间

**关键代码**:
```java
@Around("@annotation(idempotent)")
public Object around(ProceedingJoinPoint joinPoint, Idempotent idempotent) throws Throwable {
    String key = buildKey(joinPoint, idempotent, request);
    
    Boolean isNew = stringRedisTemplate.opsForValue().setIfAbsent(
        key, 
        "1", 
        idempotent.expireSeconds(), 
        TimeUnit.SECONDS
    );
    
    if (Boolean.FALSE.equals(isNew)) {
        throw new BusinessException(400, idempotent.message());
    }
    
    try {
        return joinPoint.proceed();
    } catch (Exception e) {
        stringRedisTemplate.delete(key);
        throw e;
    }
}
```

---

### 3. 使用示例

**在OrderController中应用**:
```java
@PostMapping
@Idempotent(key = "createOrder", expireSeconds = 60, message = "请勿重复提交订单")
public ApiResponse<OrderResponse> createOrder(
        HttpServletRequest request,
        @RequestBody CreateOrderRequest createOrderRequest) {
    // 业务逻辑
}

@PostMapping("/{orderNo}/pay")
@Idempotent(key = "payOrder", expireSeconds = 300, message = "请勿重复支付")
public ApiResponse<OrderResponse> payOrder(
        HttpServletRequest request,
        @PathVariable String orderNo,
        @RequestParam String payMethod) {
    // 业务逻辑
}
```

---

## 操作日志记录

### 4. @OperationLog 注解

**文件路径**: `com.healthmall.annotation.OperationLog`

**作用**: 标记需要记录操作日志的接口方法

**参数说明**:
| 参数 | 类型 | 默认值 | 说明 |
|------|------|----------|------|
| module | string | "" | 模块名称（如：订单、支付、用户） |
| operation | string | "" | 操作名称（如：创建订单、支付订单） |
| description | string | "" | 操作描述 |

---

### 5. OperationLog 实体

**文件路径**: `com.healthmall.entity.OperationLog`

**表名**: `operation_logs`

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | long | 主键 |
| userId | int | 用户ID |
| username | string | 用户名 |
| module | string | 模块名称 |
| operation | string | 操作名称 |
| description | string | 操作描述 |
| requestMethod | string | 请求方法（GET/POST/PUT/DELETE） |
| requestUrl | string | 请求URL |
| requestParams | text | 请求参数（JSON格式） |
| responseData | text | 响应数据（JSON格式） |
| ipAddress | string | 客户端IP地址 |
| executeTime | long | 执行时间（毫秒） |
| status | string | 执行状态（SUCCESS/FAILED） |
| errorMessage | text | 错误信息 |
| createdAt | datetime | 创建时间 |

---

### 6. OperationLogRepository

**文件路径**: `com.healthmall.repository.OperationLogRepository`

**提供的方法**:
```java
List<OperationLog> findByUserIdOrderByCreatedAtDesc(Integer userId);
List<OperationLog> findByModuleAndCreatedAtAfterOrderByCreatedAtDesc(
    String module, 
    LocalDateTime createdAt
);
```

---

### 7. OperationLogAspect 切面

**文件路径**: `com.healthmall.aspect.OperationLogAspect`

**实现原理**:
1. 使用`@Around`环绕通知拦截方法调用
2. 记录方法执行时间
3. 捕获请求信息（URL、参数、IP等）
4. 捕获响应数据
5. 异步保存日志，不影响主流程性能
6. 区分成功和失败状态

**关键特性**:
- 异步保存：使用`@Async`注解，不阻塞主流程
- IP获取：支持多种代理头，准确获取客户端IP
- 错误处理：保存失败不影响业务流程

---

### 8. 使用示例

**在OrderController中应用**:
```java
@PostMapping
@Idempotent(key = "createOrder", expireSeconds = 60, message = "请勿重复提交订单")
@OperationLog(module = "订单", operation = "创建订单", description = "用户创建新订单")
public ApiResponse<OrderResponse> createOrder(
        HttpServletRequest request,
        @RequestBody CreateOrderRequest createOrderRequest) {
    // 业务逻辑
}

@PostMapping("/{orderNo}/pay")
@Idempotent(key = "payOrder", expireSeconds = 300, message = "请勿重复支付")
@OperationLog(module = "支付", operation = "订单支付", description = "用户支付订单")
public ApiResponse<OrderResponse> payOrder(
        HttpServletRequest request,
        @PathVariable String orderNo,
        @RequestParam String payMethod) {
    // 业务逻辑
}

@PostMapping("/{id}/cancel")
@OperationLog(module = "订单", operation = "取消订单", description = "用户取消订单")
public ApiResponse<Void> cancelOrder(
        HttpServletRequest request,
        @PathVariable Integer id,
        @RequestParam(required = false, defaultValue = "用户取消") String reason) {
    // 业务逻辑
}
```

**在MerchantOrderController中应用**:
```java
@PostMapping("/{orderId}/confirm")
@OperationLog(module = "订单", operation = "确认订单", description = "商家确认订单")
public ApiResponse<OrderResponse> confirmOrder(
        @PathVariable Integer orderId,
        HttpServletRequest request) {
    // 业务逻辑
}

@PostMapping("/{orderId}/reject")
@OperationLog(module = "订单", operation = "拒绝订单", description = "商家拒绝订单")
public ApiResponse<OrderResponse> rejectOrder(
        @PathVariable Integer orderId,
        @RequestBody ConfirmOrderRequest request,
        HttpServletRequest httpRequest) {
    // 业务逻辑
}

@PostMapping("/{orderNo}/ship")
@OperationLog(module = "订单", operation = "订单发货", description = "商家确认订单发货")
public ApiResponse<OrderResponse> shipOrder(
    @PathVariable String orderNo,
    @RequestBody ShipOrderRequest request,
    HttpServletRequest httpRequest
) {
    // 业务逻辑
}
```

---

## 状态机配置

### 9. OrderStateMachineConfig

**文件路径**: `com.healthmall.config.OrderStateMachineConfig`

**作用**: 定义订单状态转换规则，确保状态流转的正确性

**提供的方法**:
```java
boolean canTransition(Order.OrderStatus from, Order.OrderStatus to);
void validateTransition(Order.OrderStatus from, Order.OrderStatus to);
Set<Order.OrderStatus> getNextAllowedStatuses(Order.OrderStatus currentStatus);
```

---

### 10. 订单状态转换规则

**状态转换表**:

| 当前状态 | 可转换到 | 说明 |
|----------|----------|------|
| PENDING_CONFIRMATION | CONFIRMED, REJECTED, CANCELLED | 待商家确认 → 已确认/已拒绝/已取消 |
| CONFIRMED | PENDING_PAYMENT, CANCELLED | 已确认 → 待付款/已取消 |
| REJECTED | - | 已拒绝（终态） |
| PENDING_PAYMENT | PAID, CANCELLED | 待付款 → 已付款/已取消 |
| PAID | SHIPPED, REFUNDED | 已付款 → 已发货/已退款 |
| SHIPPED | DELIVERED, REFUNDED | 已发货 → 已送达/已退款 |
| DELIVERED | COMPLETED, REFUNDED | 已送达 → 已完成/已退款 |
| COMPLETED | REFUNDED | 已完成 → 已退款 |
| CANCELLED | - | 已取消（终态） |
| REFUNDED | - | 已退款（终态） |

---

### 11. 使用示例

**在OrderService中应用**:
```java
@Autowired
private OrderStateMachineConfig stateMachineConfig;

@Transactional
public OrderResponse payOrder(Integer userId, String orderNo, Payment.PaymentMethod payMethod) {
    Order order = orderRepository.findByOrderNo(orderNo)
        .orElseThrow(() -> new BusinessException(404, "订单不存在"));
    
    // 验证状态转换
    stateMachineConfig.validateTransition(order.getStatus(), Order.OrderStatus.PAID);
    
    // 执行业务逻辑
    order.setStatus(Order.OrderStatus.PAID);
    order.setPaidAt(LocalDateTime.now());
    orderRepository.save(order);
    
    // ...
}

@Transactional
public boolean cancelOrder(Integer userId, Integer orderId, String reason) {
    Order order = orderRepository.findById(orderId)
        .orElseThrow(() -> new BusinessException(404, "订单不存在"));
    
    // 验证状态转换
    stateMachineConfig.validateTransition(order.getStatus(), Order.OrderStatus.CANCELLED);
    
    // 执行业务逻辑
    order.setStatus(Order.OrderStatus.CANCELLED);
    order.setCancelledAt(LocalDateTime.now());
    order.setCancelReason(reason);
    orderRepository.save(order);
    
    // ...
}
```

---

## 配置文件更新

### 12. pom.xml

**新增依赖**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

**说明**: 添加Spring AOP依赖，支持切面编程

---

### 13. application.yml

**新增配置**:

#### 物流配置
```yaml
logistics:
  sf:
    api-url: ${LOGISTICS_SF_API_URL:https://api.sf-express.com}
    app-key: ${LOGISTICS_SF_APP_KEY:test-key}
  sto:
    api-url: ${LOGISTICS_STO_API_URL:https://api.sto.cn}
    app-key: ${LOGISTICS_STO_APP_KEY:test-key}
  yto:
    api-url: ${LOGISTICS_YTO_API_URL:https://api.yto.net.cn}
    app-key: ${LOGISTICS_YTO_APP_KEY:test-key}
  zto:
    api-url: ${LOGISTICS_ZTO_API_URL:https://api.zto.com}
    app-key: ${LOGISTICS_ZTO_APP_KEY:test-key}
  ems:
    api-url: ${LOGISTICS_EMS_API_URL:https://api.ems.com.cn}
    app-key: ${LOGISTICS_EMS_APP_KEY:test-key}
```

#### 通知配置
```yaml
notification:
  sms:
    enabled: ${NOTIFICATION_SMS_ENABLED:false}
    provider: ${NOTIFICATION_SMS_PROVIDER:aliyun}
    access-key: ${NOTIFICATION_SMS_ACCESS_KEY:}
    secret-key: ${NOTIFICATION_SMS_SECRET_KEY:}
  email:
    enabled: ${NOTIFICATION_EMAIL_ENABLED:false}
    host: ${NOTIFICATION_EMAIL_HOST:smtp.example.com}
    port: ${NOTIFICATION_EMAIL_PORT:587}
    username: ${NOTIFICATION_EMAIL_USERNAME:}
    password: ${NOTIFICATION_EMAIL_PASSWORD:}
```

#### 风控配置
```yaml
risk:
  control:
    high-amount-threshold: ${RISK_HIGH_AMOUNT_THRESHOLD:10000}
    frequent-order-threshold: ${RISK_FREQUENT_ORDER_THRESHOLD:5}
    auto-approve-threshold: ${RISK_AUTO_APPROVE_THRESHOLD:20}
    manual-review-threshold: ${RISK_MANUAL_REVIEW_THRESHOLD:50}
```

#### 幂等性配置
```yaml
idempotent:
  enabled: ${IDEMPOTENT_ENABLED:true}
  expire-seconds: ${IDEMPOTENT_EXPIRE_SECONDS:300}
  key-prefix: ${IDEMPOTENT_KEY_PREFIX:idempotent:}
```

#### 操作日志配置
```yaml
operation-log:
  enabled: ${OPERATION_LOG_ENABLED:true}
  async: ${OPERATION_LOG_ASYNC:true}
```

---

## 应用场景总结

### 1. 支付功能

| 功能 | 实现方式 | 作用 |
|------|----------|------|
| 防止重复支付 | @Idempotent注解 | 确保同一订单不会被重复支付 |
| 记录支付操作 | @OperationLog注解 | 记录支付请求、结果、执行时间 |
| 状态流转控制 | OrderStateMachineConfig | 确保订单状态从PENDING_PAYMENT正确转换到PAID |

### 2. 发货功能

| 功能 | 实现方式 | 作用 |
|------|----------|------|
| 记录发货操作 | @OperationLog注解 | 记录商家发货操作 |
| 状态流转控制 | OrderStateMachineConfig | 确保订单状态从PAID正确转换到SHIPPED |

### 3. 订单管理

| 功能 | 实现方式 | 作用 |
|------|----------|------|
| 防止重复提交 | @Idempotent注解 | 防止用户重复创建订单 |
| 记录订单操作 | @OperationLog注解 | 记录创建、确认、拒绝、取消等操作 |
| 状态流转控制 | OrderStateMachineConfig | 确保所有订单状态转换合法 |

---

## 注意事项

1. **幂等性保障**
   - 需要Redis服务正常运行
   - 键的生成需要考虑用户身份和请求上下文
   - 方法执行失败时会自动删除锁

2. **操作日志**
   - 异步保存，不影响主流程性能
   - 敏感信息（如密码）不会被记录
   - 日志数据可用于审计、问题排查

3. **状态机**
   - 状态转换规则需要根据业务需求调整
   - 所有状态变更都应该通过状态机验证
   - 终态状态不能再转换到其他状态

4. **配置管理**
   - 生产环境建议使用环境变量覆盖默认值
   - 敏感信息（如API密钥）不要提交到代码仓库
   - 定期检查配置是否合理

---

## 后续优化建议

1. **幂等性优化**
   - 支持更灵活的键生成策略
   - 添加幂等性统计和监控

2. **操作日志优化**
   - 添加日志查询接口
   - 支持日志导出功能
   - 添加敏感数据脱敏

3. **状态机优化**
   - 添加状态转换事件监听
   - 支持状态转换前置/后置钩子
   - 添加状态转换历史记录

4. **监控告警**
   - 幂等性冲突告警
   - 操作日志异常告警
   - 状态转换异常告警
