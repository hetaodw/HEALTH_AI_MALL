package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.CreateOrderRequest;
import com.healthmall.dto.OrderResponse;
import com.healthmall.service.OrderService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 订单控制器 - 处理用户下单和订单查询
 */
@RestController
@RequestMapping("/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    /**
     * 创建订单
     * @param request HTTP请求
     * @param createOrderRequest 创建订单请求
     * @return 创建的订单信息
     */
    @PostMapping
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
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    /**
     * 获取订单详情
     * @param request HTTP请求
     * @param id 订单ID
     * @return 订单详情
     */
    @GetMapping("/{id}")
    public ApiResponse<OrderResponse> getOrderDetail(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        OrderResponse order = orderService.getOrderDetail(userId, id);
        if (order == null) {
            return ApiResponse.error(404, "订单不存在");
        }
        return ApiResponse.success(order);
    }

    /**
     * 获取当前用户的所有订单
     * @param request HTTP请求
     * @return 订单列表
     */
    @GetMapping("/my")
    public ApiResponse<List<OrderResponse>> getMyOrders(HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        List<OrderResponse> orders = orderService.getUserOrders(userId);
        return ApiResponse.success(orders);
    }

    /**
     * 取消订单
     * @param request HTTP请求
     * @param id 订单ID
     * @return 取消结果
     */
    @PostMapping("/{id}/cancel")
    public ApiResponse<Void> cancelOrder(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        boolean success = orderService.cancelOrder(userId, id);
        if (success) {
            return ApiResponse.success(null);
        } else {
            return ApiResponse.error(400, "取消订单失败，订单不存在或状态不允许取消");
        }
    }
}
