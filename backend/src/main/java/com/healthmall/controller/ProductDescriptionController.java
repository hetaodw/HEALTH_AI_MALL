package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.ProductDescriptionResponse;
import com.healthmall.service.ProductDescriptionService;
import com.healthmall.interceptor.AuthInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/product/descriptions")
public class ProductDescriptionController {

    @Autowired
    private ProductDescriptionService productDescriptionService;

    @GetMapping("/{productId}")
    public ApiResponse<ProductDescriptionResponse> getProductDescription(@PathVariable Integer productId) {
        ProductDescriptionResponse response = productDescriptionService.getProductDescriptionByProductId(productId);
        return ApiResponse.success(response);
    }

    @PostMapping("/{productId}")
    public ApiResponse<ProductDescriptionResponse> createOrUpdateProductDescription(
            @PathVariable Integer productId,
            @RequestBody Map<String, String> request,
            HttpServletRequest httpServletRequest) {
        Integer currentUserId = (Integer) httpServletRequest.getAttribute("userId");
        if (currentUserId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        String content = request.get("content");
        if (content == null || content.trim().isEmpty()) {
            return ApiResponse.error(400, "介绍内容不能为空");
        }

        ProductDescriptionResponse response = productDescriptionService.createOrUpdateProductDescription(productId, content);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{productId}")
    public ApiResponse<Void> deleteProductDescription(
            @PathVariable Integer productId,
            HttpServletRequest httpServletRequest) {
        Integer currentUserId = (Integer) httpServletRequest.getAttribute("userId");
        if (currentUserId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        productDescriptionService.deleteProductDescription(productId);
        return ApiResponse.success(null);
    }
}
