package com.healthmall.service;

import com.healthmall.dto.CreateOrderRequest;
import com.healthmall.dto.OrderResponse;
import com.healthmall.entity.Order;
import com.healthmall.entity.Product;
import com.healthmall.repository.OrderRepository;
import com.healthmall.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.stream.Collectors;

/**
 * 订单服务
 */
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductRepository productRepository;

    /**
     * 创建订单
     * @param userId 用户ID
     * @param request 创建订单请求
     * @return 订单响应DTO
     */
    @Transactional
    public OrderResponse createOrder(Integer userId, CreateOrderRequest request) {
        // 查询商品
        Optional<Product> productOpt = productRepository.findById(request.getProductId());
        if (productOpt.isEmpty()) {
            throw new RuntimeException("商品不存在");
        }

        Product product = productOpt.get();

        // 检查商品状态
        if (product.getStatus() != Product.ProductStatus.ON_SALE) {
            throw new RuntimeException("商品已下架或缺货");
        }

        // 检查库存
        if (product.getStock() < request.getQuantity()) {
            throw new RuntimeException("库存不足");
        }

        // 计算总价
        BigDecimal totalAmount = product.getPrice()
                .multiply(BigDecimal.valueOf(request.getQuantity()));

        // 创建订单
        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUserId(userId);
        order.setProductId(request.getProductId());
        order.setQuantity(request.getQuantity());
        order.setUnitPrice(product.getPrice());
        order.setTotalAmount(totalAmount);
        order.setStatus(Order.OrderStatus.PENDING_PAYMENT);
        order.setReceiverName(request.getReceiverName());
        order.setReceiverPhone(request.getReceiverPhone());
        order.setReceiverAddress(request.getReceiverAddress());
        order.setRemark(request.getRemark());

        // 保存订单
        Order savedOrder = orderRepository.save(order);

        // 扣减库存
        product.setStock(product.getStock() - request.getQuantity());
        productRepository.save(product);

        // 转换为响应DTO
        return convertToResponse(savedOrder, product);
    }

    /**
     * 获取订单详情
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 订单响应DTO
     */
    public OrderResponse getOrderDetail(Integer userId, Integer orderId) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (orderOpt.isEmpty()) {
            return null;
        }

        Order order = orderOpt.get();
        // 验证订单归属
        if (!order.getUserId().equals(userId)) {
            return null;
        }

        // 查询商品信息
        Optional<Product> productOpt = productRepository.findById(order.getProductId());
        Product product = productOpt.orElse(null);

        return convertToResponse(order, product);
    }

    /**
     * 获取用户订单列表
     * @param userId 用户ID
     * @return 订单响应DTO列表
     */
    public List<OrderResponse> getUserOrders(Integer userId) {
        List<Order> orders = orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return orders.stream()
                .map(order -> {
                    Optional<Product> productOpt = productRepository.findById(order.getProductId());
                    return convertToResponse(order, productOpt.orElse(null));
                })
                .collect(Collectors.toList());
    }

    /**
     * 取消订单
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 是否取消成功
     */
    @Transactional
    public boolean cancelOrder(Integer userId, Integer orderId) {
        Optional<Order> orderOpt = orderRepository.findById(orderId);
        if (orderOpt.isEmpty()) {
            return false;
        }

        Order order = orderOpt.get();
        // 验证订单归属
        if (!order.getUserId().equals(userId)) {
            return false;
        }

        // 只能取消待付款的订单
        if (order.getStatus() != Order.OrderStatus.PENDING_PAYMENT) {
            return false;
        }

        // 恢复库存
        Optional<Product> productOpt = productRepository.findById(order.getProductId());
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            product.setStock(product.getStock() + order.getQuantity());
            productRepository.save(product);
        }

        // 更新订单状态
        order.setStatus(Order.OrderStatus.CANCELLED);
        orderRepository.save(order);

        return true;
    }

    /**
     * 生成订单号
     * 格式: yyyyMMddHHmmss + 4位随机数
     */
    private String generateOrderNo() {
        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String random = String.format("%04d", new Random().nextInt(10000));
        return timestamp + random;
    }

    /**
     * 转换为响应DTO
     */
    private OrderResponse convertToResponse(Order order, Product product) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOrderNo(order.getOrderNo());
        response.setUserId(order.getUserId());
        response.setProductId(order.getProductId());
        response.setQuantity(order.getQuantity());
        response.setUnitPrice(order.getUnitPrice());
        response.setTotalAmount(order.getTotalAmount());
        response.setStatus(order.getStatus());
        response.setReceiverName(order.getReceiverName());
        response.setReceiverPhone(order.getReceiverPhone());
        response.setReceiverAddress(order.getReceiverAddress());
        response.setRemark(order.getRemark());
        response.setPaidAt(order.getPaidAt());
        response.setShippedAt(order.getShippedAt());
        response.setCompletedAt(order.getCompletedAt());
        response.setCreatedAt(order.getCreatedAt());

        // 设置商品信息
        if (product != null) {
            response.setProductTitle(product.getTitle());
            response.setProductCoverUrl(product.getCoverUrl());
        }

        return response;
    }
}
