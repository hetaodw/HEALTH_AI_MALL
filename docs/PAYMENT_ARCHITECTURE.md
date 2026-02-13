# 支付功能技术文档

## 文档信息

| 项目 | 内容 |
|------|------|
| 文档版本 | v1.0 |
| 创建日期 | 2026-02-13 |
| 适用项目 | Health Mall 健康商城 |
| 文档目的 | 为后续集成真实支付功能提供技术参考 |

---

## 1. 概述

本文档详细介绍健康商城项目中支付功能的现有实现架构、技术栈选择、数据流设计以及为真实支付集成预留的扩展点。当前支付功能采用**模拟实现**方式，已建立完整的支付流程框架但未对接真实支付渠道。

### 1.1 项目技术栈

| 层级 | 技术选型 |
|------|----------|
| 后端框架 | Spring Boot 3.x |
| 数据持久层 | JPA (Hibernate) + MySQL |
| 前端框架 | Vue 3 + Composition API |
| API风格 | RESTful API |
| 认证方式 | JWT Token |
| 任务调度 | Spring @Scheduled |

---

## 2. 系统架构设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              用户层                                      │
│  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐  │
│  │   Web浏览器       │    │   移动端H5       │    │   小程序         │  │
│  └────────┬─────────┘    └────────┬─────────┘    └────────┬─────────┘  │
└───────────┼──────────────────────┼──────────────────────┼─────────────┘
            │                      │                      │
            ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             前端层                                       │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        Vue 3 应用                                │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │   │
│  │  │OrderConfirm │  │  Profile    │  │   API模块   │              │   │
│  │  │  (支付UI)   │  │  (订单列表)  │  │  (请求封装)  │              │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└───────────┬──────────────────────┬──────────────────────┬─────────────┘
            │                      │                      │
            ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             服务层                                       │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Spring Boot REST API                          │   │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐    │   │
│  │  │OrderController │  │  认证拦截器     │  │  全局异常处理   │    │   │
│  │  │ (订单/支付API) │  │ (JWT验证)      │  │  (BusinessEx)  │    │   │
│  │  └────────────────┘  └────────────────┘  └────────────────┘    │   │
│  │  ┌────────────────┐  ┌────────────────┐                        │   │
│  │  │ OrderService   │  │StockReservation│                        │   │
│  │  │ (订单/支付业务) │  │    Service     │                        │   │
│  │  └────────────────┘  └────────────────┘                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└───────────┬──────────────────────┬──────────────────────┬─────────────┘
            │                      │                      │
            ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             数据层                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │
│  │   Order     │  │   Payment    │  │StockReserv  │  │  Product   │  │
│  │  订单实体   │  │   支付记录    │  │  库存预占    │  │   商品     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘  │
│                              MySQL                                       │
└─────────────────────────────────────────────────────────────────────────┘
            │
            ▼ (扩展预留)
┌─────────────────────────────────────────────────────────────────────────┐
│                          第三方支付渠道 (扩展)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │   支付宝     │  │   微信支付    │  │   银行卡     │                   │
│  │  (Alipay)   │  │  (WeChat Pay)│  │   (Bank)    │                   │
│  └──────────────┘  └──────────────┘  └──────────────┘                   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 2.2 核心模块划分

```
┌─────────────────────────────────────────────────────────────────┐
│                      支付功能核心模块                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  订单模块   │    │  支付模块   │    │  库存模块   │         │
│  │  Order     │◄──►│  Payment    │◄──►│StockReserve │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│        │                  │                  │                  │
│        ▼                  ▼                  ▼                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  OrderItem │    │ OrderResponse│   │   Product   │         │
│  │  订单商品   │    │  订单响应DTO │    │    商品     │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐                             │
│  │ OrderSnap   │    │  Scheduled  │                             │
│  │ 商品快照    │    │   定时任务   │                             │
│  └─────────────┘    └─────────────┘                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. 数据模型设计

### 3.1 支付记录表 (payments)

```sql
CREATE TABLE IF NOT EXISTS `payments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '支付ID',
    `order_no` VARCHAR(32) NOT NULL COMMENT '订单号',
    `pay_no` VARCHAR(64) DEFAULT NULL COMMENT '支付流水号',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    `pay_method` VARCHAR(20) DEFAULT NULL COMMENT '支付方式',
    `status` ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') DEFAULT 'PENDING' COMMENT '支付状态',
    `paid_at` TIMESTAMP NULL COMMENT '支付时间',
    `notify_data` TEXT DEFAULT NULL COMMENT '支付回调数据',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX `idx_order_no` (`order_no`),
    INDEX `idx_pay_no` (`pay_no`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3.2 订单表 (orders) - 支付相关字段

| 字段名 | 类型 | 说明 |
|--------|------|------|
| order_no | VARCHAR(32) | 订单号 (唯一) |
| total_amount | DECIMAL(10,2) | 订单总金额 |
| status | ENUM | 订单状态 (PENDING_PAYMENT/PAID/SHIPPED/DELIVERED/COMPLETED/CANCELLED/REFUNDED) |
| pay_expire_at | TIMESTAMP | 支付过期时间 |
| paid_at | TIMESTAMP | 支付完成时间 |
| cancelled_at | TIMESTAMP | 取消时间 |
| cancel_reason | VARCHAR(255) | 取消原因 |

### 3.3 实体类关系图

```
┌─────────────────────┐         ┌─────────────────────┐
│       Order         │ 1    *  │     OrderItem       │
│    (订单实体)        │─────────│    (订单商品项)      │
├─────────────────────┤         ├─────────────────────┤
│ - id                │         │ - id                │
│ - orderNo           │         │ - orderId (FK)      │
│ - userId            │         │ - productId         │
│ - totalAmount       │         │ - snapshotId        │
│ - status            │         │ - quantity          │
│ - payExpireAt       │         │ - unitPrice         │
│ - paidAt            │         │ - totalPrice        │
└─────────┬───────────┘         └─────────────────────┘
          │ 1:1
          ▼
┌─────────────────────┐         ┌─────────────────────┐
│      Payment        │ 1    *  │  StockReservation  │
│    (支付记录)        │─────────│    (库存预占)       │
├─────────────────────┤         ├─────────────────────┤
│ - id                │         │ - id                │
│ - orderNo (唯一)    │         │ - orderNo           │
│ - payNo             │         │ - productId        │
│ - amount            │         │ - quantity          │
│ - payMethod         │         │ - status            │
│ - status            │         │ - expireAt          │
│ - paidAt            │         └─────────────────────┘
│ - notifyData        │                 │
└─────────────────────┘                 │
                                        ▼
                               ┌─────────────────────┐
                               │      Product        │
                               │      (商品)          │
                               ├─────────────────────┤
                               │ - id                │
                               │ - stock             │
                               │ - sales             │
                               └─────────────────────┘
```

---

## 4. API接口定义

### 4.1 支付相关接口列表

| 接口路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| `/v1/orders` | POST | 创建订单 | ✅ 正常 |
| `/v1/orders/{id}` | GET | 获取订单详情 | ✅ 正常 |
| `/v1/orders/my` | GET | 获取用户订单列表 | ✅ 正常 |
| `/v1/orders/{orderNo}/pay` | POST | 支付订单 | ✅ 模拟实现 |
| `/v1/orders/{id}/cancel` | POST | 取消订单 | ✅ 正常 |

### 4.2 支付接口详细定义

#### 4.2.1 支付订单接口

**接口地址**: `POST /v1/orders/{orderNo}/pay`

**路径参数**:
| 参数 | 类型 | 说明 |
|------|------|------|
| orderNo | string | 订单号 |

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| payMethod | string | 是 | 支付方式 |

**支付方式枚举**:
| 值 | 说明 |
|----|------|
| ALIPAY | 支付宝 |
| WECHAT | 微信支付 |
| BANK | 银行卡 |

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "orderNo": "280686617910448128",
    "totalAmount": 99.00,
    "status": "PAID",
    "paidAt": "2026-02-13T10:30:00",
    "items": [...]
  }
}
```

**错误响应**:
| 状态码 | 说明 |
|--------|------|
| 400 | 订单不存在/状态不允许支付/支付超时 |
| 401 | 未登录 |
| 403 | 无权操作此订单 |

---

## 5. 支付流程设计

### 5.1 整体流程图

```
用户点击"立即支付"
        │
        ▼
┌───────────────────┐
│  打开支付弹窗      │
│  (选择支付方式)    │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  用户选择支付方式  │
│  并点击确认支付   │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  调用支付API      │
│ POST /orders/{    │
│   orderNo}/pay   │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐     ┌─────────────────────┐
│  验证订单状态      │────►│  检查订单是否存在    │
└─────────┬─────────┘     └─────────────────────┘
          │
          ▼
    ┌─────────────┐      ┌─────────────────────┐
    │ 验证支付方式 │────►│ 检查支付方式是否有效  │
    └─────────────┘      └─────────────────────┘
          │
          ▼
    ┌─────────────┐      ┌─────────────────────┐
    │ 验证支付时限 │────►│ 检查是否超过支付时间 │
    └─────────────┘      └─────────────────────┘
          │
          ▼
┌───────────────────┐
│  ⭐ 创建支付记录   │  ◄── 当前为模拟实现
│  (Payment)        │      直接设为SUCCESS
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  ⭐ 更新订单状态   │
│  Order:PAID       │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  ⭐ 确认库存预占   │
│  CONFIRMED        │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  ⭐ 扣减实际库存   │
│  deductStock      │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  返回订单详情     │
└─────────┬─────────┘
          │
          ▼
    前端更新订单状态
          │
          ▼
    展示支付成功界面
```

### 5.2 支付核心代码实现

**OrderService.payOrder 方法** (位于 [OrderService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/OrderService.java#L199-L233)):

```java
@Transactional
public OrderResponse payOrder(Integer userId, String orderNo, Payment.PaymentMethod payMethod) {
    // 1. 获取订单并验证权限
    Order order = orderRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new BusinessException(404, "订单不存在"));

    if (!order.getUserId().equals(userId)) {
        throw new BusinessException(403, "无权操作此订单");
    }

    // 2. 验证订单状态
    if (order.getStatus() != Order.OrderStatus.PENDING_PAYMENT) {
        throw new BusinessException(400, "订单状态不允许支付");
    }

    // 3. 验证支付时限
    if (LocalDateTime.now().isAfter(order.getPayExpireAt())) {
        cancelOrder(userId, order.getId(), "支付超时");
        throw new BusinessException(400, "订单已超时，请重新下单");
    }

    // 4. ⭐ 创建支付记录 (模拟实现 - 直接成功)
    Payment payment = new Payment();
    payment.setOrderNo(orderNo);
    payment.setAmount(order.getTotalAmount());
    payment.setPayMethod(payMethod);
    payment.setStatus(Payment.PaymentStatus.SUCCESS);  // 直接设为成功
    payment.setPayNo("PAY" + idGenerator.generateOrderNo());
    payment.setPaidAt(LocalDateTime.now());
    paymentRepository.save(payment);

    // 5. ⭐ 更新订单状态为已付款
    order.setStatus(Order.OrderStatus.PAID);
    order.setPaidAt(LocalDateTime.now());
    orderRepository.save(order);

    // 6. 确认库存预占
    confirmStockReservation(orderNo);

    // 7. 扣减实际库存
    deductStockFromDb(orderNo);

    return getOrderDetail(userId, order.getId());
}
```

---

## 6. 状态管理机制

### 6.1 支付状态枚举

**PaymentStatus** (位于 [Payment.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/Payment.java#L10-L16)):

```java
public enum PaymentStatus {
    PENDING,    // 待支付 - 支付记录已创建，等待用户支付
    SUCCESS,    // 支付成功 - 收到支付成功回调
    FAILED,     // 支付失败 - 支付失败或回调通知失败
    REFUNDED    // 已退款 - 已完成退款操作
}
```

### 6.2 订单状态枚举

**OrderStatus**:

```java
public enum OrderStatus {
    PENDING_PAYMENT,    // 待付款 - 订单已创建，等待用户支付
    PAID,               // 已付款 - 支付成功，库存已扣减
    SHIPPED,            // 已发货 - 商家已发货
    DELIVERED,          // 已送达 - 已送达用户手中
    COMPLETED,          // 已完成 - 用户确认收货
    CANCELLED,          // 已取消 - 订单已取消
    REFUNDED            // 已退款 - 已完成退款
}
```

### 6.3 状态流转图

```
创建订单
   │
   ▼
PENDING_PAYMENT ──15分钟超时──► CANCELLED
   │                              ▲
   │ (用户支付)                   │ (系统取消)
   ▼                             │
  PAID ◄───── 退款 ──────────────┘
   │
   │ (商家发货)
   ▼
 SHIPPED
   │
   │ (送达)
   ▼
DELIVERED
   │
   │ (确认收货)
   ▼
COMPLETED
```

---

## 7. 模拟实现说明

### 7.1 当前实现方式

当前支付功能采用**同步模拟实现**，具体表现为：

1. **支付即时成功**: 调用支付接口后，无需等待第三方支付渠道返回，直接将支付状态设为 `SUCCESS`
2. **无异步回调**: 未实现支付回调接口 (Callback/Webhook)
3. **生成模拟流水号**: 使用内部ID生成器生成 `PAY` 开头的模拟支付流水号
4. **库存同步处理**: 支付成功后立即执行库存扣减逻辑

### 7.2 代码位置

| 功能 | 文件位置 |
|------|----------|
| 支付核心逻辑 | [OrderService.payOrder()](file:///d:/26bs/backend/src/main/java/com/healthmall/service/OrderService.java#L199-L233) |
| 支付记录创建 | [Payment.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/Payment.java) (L199-207行) |
| 支付状态枚举 | [Payment.PaymentStatus](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/Payment.java#L10-L16) |
| 支付API路由 | [OrderController](file:///d:/26bs/backend/src/main/java/com/healthmall/controller/OrderController.java#L82-L103) |
| 前端支付UI | [OrderConfirm.vue](file:///d:/26bs/frontend/src/views/OrderConfirm.vue#L260-L285) |

### 7.3 模拟实现代码片段

```java
// OrderService.java 第199-210行
// ⭐ 模拟支付实现 - 直接成功
Payment payment = new Payment();
payment.setOrderNo(orderNo);
payment.setAmount(order.getTotalAmount());
payment.setPayMethod(payMethod);
payment.setStatus(Payment.PaymentStatus.SUCCESS);  // 直接设为成功，无需第三方回调
payment.setPayNo("PAY" + idGenerator.generateOrderNo());  // 模拟支付流水号
payment.setPaidAt(LocalDateTime.now());
paymentRepository.save(payment);
```

---

## 8. 与其他模块的交互关系

### 8.1 模块依赖关系

```
┌─────────────────────────────────────────────────────────────────┐
│                        支付模块依赖关系                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    支付模块                                                      │
│       │                                                          │
│       ├──────┬──────────────┬──────────────┬─────────────┐      │
│       │      │              │              │             │      │
│       ▼      ▼              ▼              ▼             ▼      │
│   ┌──────┐ ┌──────┐   ┌──────┐    ┌──────┐      ┌──────┐    │
│   │订单模块│ │库存模块│   │用户模块│    │商品模块│      │定时任务│
│   │      │ │      │   │      │    │      │      │      │    │
│   │Order │ │Stock │   │ User │    │Product│      │Schedule│
│   │Service│ │Reserve│   │Service│   │Service│      │Task   │
│   └──┬───┘ └──┬───┘   └──┬───┘    └──┬───┘      └───┬────┘    │
│      │        │          │           │             │         │
│      └────────┴──────────┴───────────┴─────────────┘         │
│                         数据层                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 核心交互说明

| 交互模块 | 交互内容 | 调用方式 |
|----------|----------|----------|
| **订单模块** | 创建支付记录、更新订单状态 | OrderService 直接调用 |
| **库存模块** | 确认预占、扣减库存 | StockReservationService |
| **用户模块** | 验证用户身份、获取用户信息 | 通过 JWT Token 解析 |
| **商品模块** | 获取商品信息、创建商品快照 | ProductRepository |
| **定时任务** | 取消超时订单、清理过期预占 | OrderScheduledTask |

### 8.3 关键服务依赖

**OrderService 依赖注入** (位于 [OrderService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/OrderService.java#L24-L47)):

```java
@Autowired
private OrderRepository orderRepository;

@Autowired
private OrderItemRepository orderItemRepository;

@Autowired
private ProductRepository productRepository;

@Autowired
private ProductSnapshotRepository snapshotRepository;

@Autowired
private AddressRepository addressRepository;

@Autowired
private StockReservationRepository reservationRepository;

@Autowired
private PaymentRepository paymentRepository;  // 支付记录仓储

@Autowired
private UserRepository userRepository;

@Autowired
private SnowflakeIdGenerator idGenerator;

@Autowired
private StockReservationService stockReservationService;  // 库存预占服务
```

---

## 9. 扩展点与集成接口

### 9.1 为真实支付预留的扩展点

#### 9.1.1 支付策略模式扩展

建议使用策略模式实现多支付渠道统一管理：

```
┌─────────────────────────────┐
│      PaymentStrategy        │
│         (接口)              │
├─────────────────────────────┤
│ + createPayment()           │
│ + queryPaymentStatus()      │
│ + handleCallback()          │
│ + refund()                  │
└──────────────┬──────────────┘
               │
       ┌───────┼───────┐
       │       │       │
       ▼       ▼       ▼
  ┌────────┐ ┌────────┐ ┌────────┐
  │ Alipay │ │ WeChat │ │  Bank  │
  │Strategy│ │Strategy│ │Strategy│
  └────────┘ └────────┘ └────────┘
```

#### 9.1.2 支付回调接口设计

```java
// 建议新增 PaymentCallbackController
@RestController
@RequestMapping("/v1/payment/callback")
public class PaymentCallbackController {

    @PostMapping("/alipay")
    public ApiResponse<Void> alipayCallback(@RequestParam String orderNo, 
                                             @RequestParam String tradeNo,
                                             @RequestParam String tradeStatus) {
        // TODO: 实现支付宝异步回调处理
        // 1. 验证签名
        // 2. 更新支付状态
        // 3. 更新订单状态
        return ApiResponse.success(null);
    }

    @PostMapping("/wechat")
    public ApiResponse<Void> wechatCallback(@RequestBody String xmlData) {
        // TODO: 实现微信支付异步回调处理
        return ApiResponse.success(null);
    }
}
```

#### 9.1.3 支付记录扩展字段

当前 `notify_data` 字段可用于存储第三方支付回调原始数据，建议后续扩展：

| 字段 | 类型 | 说明 |
|------|------|------|
| notify_data | TEXT | 回调原始数据 (JSON/XML) |
| (建议扩展) callback_sign | VARCHAR(255) | 回调签名 |
| (建议扩展) transaction_id | VARCHAR(64) | 第三方交易号 |
| (建议扩展) trade_type | VARCHAR(20) | 交易类型 |

### 9.2 扩展接口清单

| 扩展项 | 接口位置 | 建议新增方法 | 优先级 |
|--------|----------|--------------|--------|
| 支付回调 | 新增 Controller | `alipayCallback()`, `wechatCallback()` | 高 |
| 支付查询 | OrderService | `queryPaymentStatus()` | 高 |
| 退款功能 | OrderService | `refundOrder()` | 中 |
| 支付取消 | OrderService | `cancelPayment()` | 中 |
| 对账单 | 新增 Service | `downloadBill()` | 低 |

---

## 10. 当前限制与假设

### 10.1 功能限制

| 限制项 | 当前状态 | 影响说明 |
|--------|----------|----------|
| **支付方式** | 仅支持枚举定义的三种 | 实际未对接第三方 |
| **异步回调** | 未实现 | 无法处理支付异步通知 |
| **支付超时** | 15分钟固定 | 无法自定义不同商品超时时间 |
| **退款功能** | 未实现 | 无法处理退款场景 |
| **支付重试** | 未实现 | 支付失败后无法重试 |
| **多货币** | 不支持 | 仅支持人民币 |
| **优惠券** | 未集成 | 支付金额未扣除优惠 |

### 10.2 技术假设

1. **订单金额一致性**: 假设创建订单与支付时金额一致，未做金额校验
2. **单次支付**: 不支持分期付款、合并支付等复杂场景
3. **用户身份**: 依赖 JWT Token 验证，后续需确保 Token 安全
4. **并发控制**: 使用数据库事务，但未做分布式锁

### 10.3 数据假设

1. 支付记录与订单一一对应 (1:1)
2. 支付成功后立即扣减库存 (非异步队列)
3. 不存在重复支付场景

---

## 11. 真实支付集成指南

### 11.1 支付宝集成步骤

1. **注册支付宝商户号**: 在支付宝开放平台申请商户资格
2. **配置应用**: 创建应用并获取 AppID 和密钥
3. **引入SDK**: 添加支付宝SDK依赖
   ```xml
   <!-- 建议添加 -->
   <dependency>
       <groupId>com.alipay.sdk</groupId>
       <artifactId>alipay-sdk-java</artifactId>
       <version>4.x.x</version>
   </dependency>
   ```
4. **创建支付策略**: 实现 `AlipayPaymentStrategy`
5. **实现回调接口**: 创建支付宝异步通知接收接口
6. **配置密钥**: 在配置文件中添加支付宝密钥

### 11.2 微信支付集成步骤

1. **注册微信商户号**: 在微信商户平台申请商户资格
2. **获取API密钥**: 获取商户号、API密钥、证书
3. **引入SDK**: 添加微信支付V3版SDK
4. **创建支付策略**: 实现 `WechatPaymentStrategy`
5. **实现回调接口**: 创建微信支付回调接收接口 (需处理XML/JSON)
6. **配置证书**: 配置API证书和商户密钥

### 11.3 集成检查清单

- [ ] 选择支付渠道并注册商户
- [ ] 获取商户凭据 (AppID, 密钥, 证书)
- [ ] 引入对应支付渠道SDK
- [ ] 设计支付策略接口/抽象类
- [ ] 实现各渠道支付策略
- [ ] 创建支付回调控制器
- [ ] 实现回调签名验证
- [ ] 更新支付状态和订单状态逻辑
- [ ] 编写集成测试用例
- [ ] 配置生产环境参数
- [ ] 了解各渠道手续费政策

---

## 12. 附录

### 12.1 相关文件清单

| 分类 | 文件路径 | 说明 |
|------|----------|------|
| **后端-实体** | [backend/.../entity/Payment.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/Payment.java) | 支付记录实体 |
| **后端-实体** | [backend/.../entity/Order.java](file:///d:/26bs/backend/src/main/java/com/healthmall/entity/Order.java) | 订单实体 |
| **后端-服务** | [backend/.../service/OrderService.java](file:///d:/26bs/backend/src/main/java/com/healthmall/service/OrderService.java) | 订单/支付服务 |
| **后端-控制** | [backend/.../controller/OrderController.java](file:///d:/26bs/backend/src/main/java/com/healthmall/controller/OrderController.java) | 订单控制器 |
| **后端-仓储** | [backend/.../repository/PaymentRepository.java](file:///d:/26bs/backend/src/main/java/com/healthmall/repository/PaymentRepository.java) | 支付仓储 |
| **后端-任务** | [backend/.../task/OrderScheduledTask.java](file:///d:/26bs/backend/src/main/java/com/healthmall/task/OrderScheduledTask.java) | 定时任务 |
| **后端-数据库** | [backend/.../db/order_schema.sql](file:///d:/26bs/backend/src/main/resources/db/order_schema.sql) | 数据库脚本 |
| **前端-视图** | [frontend/.../views/OrderConfirm.vue](file:///d:/26bs/frontend/src/views/OrderConfirm.vue) | 订单确认页/支付UI |
| **前端-API** | [frontend/.../api/index.js](file:///d:/26bs/frontend/src/api/index.js) | API封装 |
| **文档** | [docs/API_DOCUMENTATION.md](file:///d:/26bs/docs/API_DOCUMENTATION.md) | API文档 |

### 12.2 数据库表汇总

| 表名 | 说明 | 支付相关字段 |
|------|------|-------------|
| orders | 订单表 | status, pay_expire_at, paid_at, cancelled_at |
| payments | 支付记录表 | 全部字段 |
| stock_reservations | 库存预占表 | status, expire_at |
| products | 商品表 | stock, sales |
| order_items | 订单商品项表 | 全部字段 |
| product_snapshots | 商品快照表 | 全部字段 |

### 12.3 API响应格式

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { }
}
```

**通用状态码**:
| code | 说明 |
|------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录 |
| 403 | 无权访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 13. 文档修订历史

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v1.0 | 2026-02-13 | 技术团队 | 初始版本 |

---

*本文档为支付功能技术参考文档，将持续更新以反映系统演进。*
