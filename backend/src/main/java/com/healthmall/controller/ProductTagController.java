package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.BatchGenerateRequest;
import com.healthmall.dto.BatchGenerateResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.dto.ProductListItem;
import com.healthmall.dto.TagStatistics;
import com.healthmall.dto.UpdateTagsRequest;
import com.healthmall.service.ProductTagService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/products/tags")
public class ProductTagController {

    @Autowired
    private ProductTagService productTagService;

    @PostMapping("/{productId}/generate")
    public ApiResponse<List<String>> generateTags(@PathVariable Integer productId) {
        List<String> tags = productTagService.generateTagsForProduct(productId);
        return ApiResponse.success(tags);
    }

    @PostMapping("/batch/generate")
    public ApiResponse<BatchGenerateResponse> generateTagsBatch(@RequestBody BatchGenerateRequest request) {
        BatchGenerateResponse response = productTagService.generateTagsForProducts(request.getProductIds());
        return ApiResponse.success(response);
    }

    @GetMapping("/{productId}")
    public ApiResponse<List<String>> getProductTags(@PathVariable Integer productId) {
        List<String> tags = productTagService.getProductTags(productId);
        return ApiResponse.success(tags);
    }

    @PutMapping("/{productId}")
    public ApiResponse<Void> updateTags(
            @PathVariable Integer productId,
            @RequestBody UpdateTagsRequest request) {
        productTagService.updateProductTags(productId, request.getTags());
        return ApiResponse.success();
    }

    @GetMapping("/popular")
    public ApiResponse<List<TagStatistics>> getPopularTags(
            @RequestParam(defaultValue = "20") Integer limit) {
        List<TagStatistics> statistics = productTagService.getPopularTags(limit);
        return ApiResponse.success(statistics);
    }

    @GetMapping("/search")
    public ApiResponse<PageResponse<ProductListItem>> searchByTags(
            @RequestParam List<String> tags,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        PageResponse<ProductListItem> response = productTagService.searchByTags(tags, page, size);
        return ApiResponse.success(response);
    }
}
