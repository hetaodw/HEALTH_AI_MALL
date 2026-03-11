package com.healthmall.controller;

import com.healthmall.annotation.Idempotent;
import com.healthmall.annotation.OperationLog;
import com.healthmall.common.ApiResponse;
import com.healthmall.dto.CreateOrderRequest;
import com.healthmall.dto.OrderResponse;
import com.healthmall.entity.Order;
import com.healthmall.entity.Payment;
import com.healthmall.exception.BusinessException;
import com.healthmall.service.OrderService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping
    @Idempotent(key = "createOrder", expireSeconds = 60, message = "请勿重复提交订单")
    @OperationLog(module = "订单", operation = "创建订单", description = "用户创建新订单")
    public ApiResponse<OrderResponse> createOrder(
            HttpServletRequest request,
            @RequestBody CreateOrderRequest createOrderRequest) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            OrderResponse order = orderService.createOrder(userId, createOrderRequest);
            return ApiResponse.success(order);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> getOrderDetail(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            OrderResponse order = orderService.getOrderDetail(userId, id);
            return ApiResponse.success(order);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @GetMapping("/my")
    public ApiResponse<List<OrderResponse>> getMyOrders(
            HttpServletRequest request,
            @RequestParam(required = false) String status) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        Order.OrderStatus orderStatus = null;
        if (status != null && !status.isEmpty()) {
            try {
                orderStatus = Order.OrderStatus.valueOf(status);
            } catch (IllegalArgumentException e) {
                return ApiResponse.error(400, "无效的订单状态");
            }
        }

        List<OrderResponse> orders = orderService.getUserOrders(userId, orderStatus);
        return ApiResponse.success(orders);
    }

    @PostMapping("/{orderNo}/pay")
    @Idempotent(key = "payOrder", expireSeconds = 300, message = "请勿重复支付")
    @OperationLog(module = "支付", operation = "订单支付", description = "用户支付订单")
    public ApiResponse<OrderResponse> payOrder(
            HttpServletRequest request,
            @PathVariable String orderNo,
            @RequestParam String payMethod) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        Payment.PaymentMethod method;
        try {
            method = Payment.PaymentMethod.valueOf(payMethod.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ApiResponse.error(400, "无效的支付方式");
        }

        try {
            OrderResponse order = orderService.payOrder(userId, orderNo, method);
            return ApiResponse.success(order);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @PostMapping("/{id}/cancel")
    @OperationLog(module = "订单", operation = "取消订单", description = "用户取消订单")
    public ApiResponse<Void> cancelOrder(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestParam(required = false, defaultValue = "用户取消") String reason) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            orderService.cancelOrder(userId, id, reason);
            return ApiResponse.success(null);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }
}
