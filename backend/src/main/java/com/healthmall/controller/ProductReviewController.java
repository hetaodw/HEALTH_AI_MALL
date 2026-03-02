package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.ProductReviewRequest;
import com.healthmall.dto.ProductReviewResponse;
import com.healthmall.interceptor.AuthInterceptor;
import com.healthmall.service.ProductReviewService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/product/reviews")
public class ProductReviewController {

    @Autowired
    private ProductReviewService productReviewService;

    @GetMapping("/{productId}")
    public ApiResponse<Map<String, Object>> getProductReviews(
            @PathVariable Integer productId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        
        List<ProductReviewResponse> reviews = productReviewService.getProductReviews(productId, page, size);
        Double averageRating = productReviewService.getProductAverageRating(productId);
        Long reviewCount = productReviewService.getProductReviewCount(productId);

        Map<String, Object> response = new HashMap<>();
        response.put("list", reviews);
        response.put("averageRating", averageRating != null ? averageRating : 0.0);
        response.put("reviewCount", reviewCount != null ? reviewCount : 0);
        response.put("page", page);
        response.put("size", size);

        return ApiResponse.success(response);
    }

    @GetMapping("/detail/{reviewId}")
    public ApiResponse<ProductReviewResponse> getProductReview(@PathVariable Integer reviewId) {
        ProductReviewResponse response = productReviewService.getProductReview(reviewId);
        return ApiResponse.success(response);
    }

    @PostMapping("/{productId}")
    public ApiResponse<ProductReviewResponse> createProductReview(
            @PathVariable Integer productId,
            @RequestBody ProductReviewRequest request,
            HttpServletRequest httpServletRequest) {
        Integer currentUserId = (Integer) httpServletRequest.getAttribute("userId");
        if (currentUserId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        if (request.getRating() == null) {
            return ApiResponse.error(400, "评分不能为空");
        }

        ProductReviewResponse response = productReviewService.createReview(
                productId, 
                currentUserId, 
                request.getRating(), 
                request.getTitle(), 
                request.getContent(), 
                request.getIsAnonymous()
        );
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{reviewId}")
    public ApiResponse<Void> deleteProductReview(
            @PathVariable Integer reviewId,
            HttpServletRequest httpServletRequest) {
        Integer currentUserId = (Integer) httpServletRequest.getAttribute("userId");
        if (currentUserId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        productReviewService.deleteReview(reviewId, currentUserId);
        return ApiResponse.success(null);
    }
}
