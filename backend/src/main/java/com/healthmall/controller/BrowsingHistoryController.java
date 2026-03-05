package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.BrowsingHistoryItem;
import com.healthmall.dto.PageResponse;
import com.healthmall.service.BrowsingHistoryService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/browsing-history")
public class BrowsingHistoryController {

    @Autowired
    private BrowsingHistoryService browsingHistoryService;

    @GetMapping
    public ApiResponse<PageResponse<BrowsingHistoryItem>> getBrowsingHistory(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {
        Integer userId = (Integer) request.getAttribute("userId");
        PageResponse<BrowsingHistoryItem> response = browsingHistoryService.getBrowsingHistory(userId, page, size);
        return ApiResponse.success(response);
    }

    @PostMapping("/{productId}")
    public ApiResponse<Void> addBrowsingHistory(
            @PathVariable Integer productId,
            HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        browsingHistoryService.addBrowsingHistory(userId, productId);
        return ApiResponse.success();
    }

    @DeleteMapping("/{productId}")
    public ApiResponse<Void> deleteBrowsingHistory(
            @PathVariable Integer productId,
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
