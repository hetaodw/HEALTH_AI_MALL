package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.dto.ProductDetailResponse;
import com.healthmall.dto.ProductListItem;
import com.healthmall.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    public ApiResponse<PageResponse<ProductListItem>> getProductList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Boolean isHot,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) String sortOrder) {
        PageResponse<ProductListItem> response = productService.getProductList(
                page, size, isHot, category, minPrice, maxPrice, sortBy, sortOrder);
        return ApiResponse.success(response);
    }

    @GetMapping("/search")
    public ApiResponse<PageResponse<ProductListItem>> searchProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        PageResponse<ProductListItem> response = productService.searchProducts(
                keyword, minPrice, maxPrice, sortBy, page, size);
        return ApiResponse.success(response);
    }

    @GetMapping("/hot")
    public ApiResponse<List<ProductListItem>> getHotProducts(
            @RequestParam(defaultValue = "10") Integer limit) {
        List<ProductListItem> response = productService.getHotProducts(limit);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<ProductDetailResponse> getProductDetail(@PathVariable Integer id) {
        ProductDetailResponse response = productService.getProductDetail(id);
        return ApiResponse.success(response);
    }

    @GetMapping("/category/{category}")
    public ApiResponse<PageResponse<ProductListItem>> getProductsByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        PageResponse<ProductListItem> response = productService.getProductsByCategory(category, page, size);
        return ApiResponse.success(response);
    }
}
