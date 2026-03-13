package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.BrowsingHistoryItem;
import com.healthmall.dto.PageResponse;
import com.healthmall.entity.Product;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductRepository;
import com.healthmall.service.BrowsingHistoryService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.constraints.Min;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/browsing-history")
public class BrowsingHistoryController {

    @Autowired
    private BrowsingHistoryService browsingHistoryService;

    @Autowired
    private ProductRepository productRepository;

    @GetMapping
    public ApiResponse<PageResponse<BrowsingHistoryItem>> getBrowsingHistory(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @RequestParam(defaultValue = "20") @Min(1) Integer size) {
        Integer userId = (Integer) request.getAttribute("userId");
        PageResponse<BrowsingHistoryItem> response = browsingHistoryService.getBrowsingHistory(userId, page, size);
        return ApiResponse.success(response);
    }

    @PostMapping("/{productId}")
    public ApiResponse<Void> addBrowsingHistory(
            @PathVariable @Min(1) Integer productId,
            HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new BusinessException("商品不存在"));
        
        browsingHistoryService.addBrowsingHistory(userId, productId);
        return ApiResponse.success();
    }

    @DeleteMapping("/{productId}")
    public ApiResponse<Void> deleteBrowsingHistory(
            @PathVariable @Min(1) Integer productId,
            HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        browsingHistoryService.deleteBrowsingHistory(userId, productId);
        return ApiResponse.success();
    }

    @DeleteMapping
    public ApiResponse<Void> clearBrowsingHistory(HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        browsingHistoryService.clearBrowsingHistory(userId);
        return ApiResponse.success();
    }
}
