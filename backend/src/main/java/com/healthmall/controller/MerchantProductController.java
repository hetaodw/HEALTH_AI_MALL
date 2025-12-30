package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.MerchantProductRequest;
import com.healthmall.dto.MerchantProductResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.entity.Product;
import com.healthmall.service.MerchantProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/merchant/products")
public class MerchantProductController {

    @Autowired
    private MerchantProductService merchantProductService;

    @PostMapping
    public ApiResponse<MerchantProductResponse> addProduct(
            HttpServletRequest request,
            @RequestBody MerchantProductRequest productRequest) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        MerchantProductResponse response = merchantProductService.addProduct(merchantId, productRequest);
        return ApiResponse.success(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<MerchantProductResponse> updateProduct(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestBody MerchantProductRequest productRequest) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        MerchantProductResponse response = merchantProductService.updateProduct(merchantId, id, productRequest);
        return ApiResponse.success(response);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteProduct(
            HttpServletRequest request,
            @PathVariable Integer id) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        merchantProductService.deleteProduct(merchantId, id);
        return ApiResponse.success();
    }

    @GetMapping
    public ApiResponse<PageResponse<MerchantProductResponse>> getMerchantProducts(
            HttpServletRequest request,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String category) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        PageResponse<MerchantProductResponse> response = merchantProductService.getMerchantProducts(
                merchantId, page, size, status, category);
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<MerchantProductResponse> getMerchantProductDetail(
            HttpServletRequest request,
            @PathVariable Integer id) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        MerchantProductResponse response = merchantProductService.getProduct(merchantId, id);
        return ApiResponse.success(response);
    }

    @PatchMapping("/{id}/status")
    public ApiResponse<Void> updateProductStatus(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestParam String status) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        Product.ProductStatus productStatus = Product.ProductStatus.valueOf(status.toUpperCase());
        merchantProductService.updateProductStatus(merchantId, id, productStatus);
        return ApiResponse.success();
    }

    @PatchMapping("/{id}/stock")
    public ApiResponse<Void> updateProductStock(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestParam Integer stock) {
        Integer merchantId = (Integer) request.getAttribute("userId");
        merchantProductService.updateProductStock(merchantId, id, stock);
        return ApiResponse.success();
    }
}
