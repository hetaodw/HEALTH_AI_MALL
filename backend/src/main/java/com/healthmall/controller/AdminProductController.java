package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.service.FileUploadService;
import com.healthmall.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;

@RestController
@RequestMapping("/admin/products")
public class AdminProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private FileUploadService fileUploadService;

    @PostMapping
    public ApiResponse<Integer> createProduct(
            @RequestParam("name") String name,
            @RequestParam("category") String category,
            @RequestParam("price") BigDecimal price,
            @RequestParam("stock") Integer stock,
            @RequestParam("description") String description,
            @RequestParam("coverImage") MultipartFile coverImage,
            @RequestParam(value = "features", required = false) String features,
            HttpServletRequest httpRequest) {
        
        try {
            // 上传封面图片
            String coverUrl = fileUploadService.uploadImage(coverImage, "product-cover");
            
            Integer productId = productService.createProduct(
                    name,
                    category,
                    price,
                    stock,
                    description,
                    coverUrl,
                    features
            );
            return ApiResponse.success(productId);
        } catch (Exception e) {
            return ApiResponse.error(500, "商品创建失败: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteProduct(@PathVariable Integer id) {
        return ApiResponse.success();
    }
}
