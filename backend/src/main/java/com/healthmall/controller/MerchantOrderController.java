package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.ConfirmOrderRequest;
import com.healthmall.dto.OrderResponse;
import com.healthmall.entity.Order;
import com.healthmall.service.OrderService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/merchant/orders")
public class MerchantOrderController {

    @Autowired
    private OrderService orderService;

    @GetMapping("/pending")
    public ApiResponse<List<OrderResponse>> getPendingOrders(HttpServletRequest request) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        if (merchantId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        List<OrderResponse> orders = orderService.getMerchantOrders(merchantId, Order.OrderStatus.PENDING_CONFIRMATION);
        return ApiResponse.success(orders);
    }

    @GetMapping
    public ApiResponse<List<OrderResponse>> getOrders(
            @RequestParam(required = false) String status,
            HttpServletRequest request) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        if (merchantId == null) {
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

        List<OrderResponse> orders = orderService.getMerchantOrders(merchantId, orderStatus);
        return ApiResponse.success(orders);
    }

    @PostMapping("/{orderId}/confirm")
    public ApiResponse<OrderResponse> confirmOrder(
            @PathVariable Integer orderId,
            HttpServletRequest request) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        if (merchantId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        OrderResponse response = orderService.confirmOrder(merchantId, orderId);
        return ApiResponse.success(response);
    }

    @PostMapping("/{orderId}/reject")
    public ApiResponse<OrderResponse> rejectOrder(
            @PathVariable Integer orderId,
            @RequestBody ConfirmOrderRequest request,
            HttpServletRequest request) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        if (merchantId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        OrderResponse response = orderService.rejectOrder(merchantId, orderId, request.getRejectReason());
        return ApiResponse.success(response);
    }
}
