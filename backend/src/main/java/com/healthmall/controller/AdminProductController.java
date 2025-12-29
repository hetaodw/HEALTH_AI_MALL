package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.AddProductRequest;
import com.healthmall.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/products")
public class AdminProductController {

    @Autowired
    private ProductService productService;

    @PostMapping
    public ApiResponse<Integer> createProduct(@RequestBody AddProductRequest request, HttpServletRequest httpRequest) {
        Integer productId = productService.createProduct(
                request.getName(),
                request.getCategory(),
                request.getPrice(),
                request.getStock(),
                request.getDescription(),
                request.getCoverUrl(),
                request.getFeatures()
        );
        return ApiResponse.success(productId);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteProduct(@PathVariable Integer id) {
        return ApiResponse.success();
    }
}
