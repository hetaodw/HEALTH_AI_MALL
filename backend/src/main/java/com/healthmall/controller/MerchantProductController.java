package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.MerchantProductRequest;
import com.healthmall.dto.MerchantProductResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.entity.Product;
import com.healthmall.service.FileUploadService;
import com.healthmall.service.MerchantProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.ArrayList;

@RestController
@RequestMapping("/merchant/products")
public class MerchantProductController {

    @Autowired
    private MerchantProductService merchantProductService;

    @Autowired
    private FileUploadService fileUploadService;

    @PostMapping
    public ApiResponse<MerchantProductResponse> addProduct(
            HttpServletRequest request,
            @RequestParam("title") String title,
            @RequestParam("category") String category,
            @RequestParam("price") BigDecimal price,
            @RequestParam("stock") Integer stock,
            @RequestParam("description") String description,
            @RequestParam("coverImage") MultipartFile coverImage,
            @RequestParam(value = "features", required = false) String features,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "detailImages", required = false) List<MultipartFile> detailImages) {
        
        Integer merchantId = (Integer) request.getAttribute("userId");
        
        try {
            // 上传封面图片
            String coverUrl = fileUploadService.uploadImage(coverImage, "product-cover");
            
            // 上传详细介绍图片
            List<String> detailImageUrls = new java.util.ArrayList<>();
            if (detailImages != null && !detailImages.isEmpty()) {
                for (MultipartFile image : detailImages) {
                    if (!image.isEmpty()) {
                        String imageUrl = fileUploadService.uploadImage(image, "product-detail");
                        detailImageUrls.add(imageUrl);
                    }
                }
            }
            
            // 构建请求对象
            MerchantProductRequest productRequest = new MerchantProductRequest();
            productRequest.setTitle(title);
            productRequest.setCategory(category);
            productRequest.setPrice(price);
            productRequest.setStock(stock);
            productRequest.setDescription(description);
            productRequest.setCoverUrl(coverUrl);
            productRequest.setFeatures(features);
            productRequest.setDetailImages(detailImageUrls);
            if (status != null) {
                productRequest.setStatus(Product.ProductStatus.valueOf(status.toUpperCase()));
            }
            
            MerchantProductResponse response = merchantProductService.addProduct(merchantId, productRequest);
            return ApiResponse.success(response);
        } catch (Exception e) {
            return ApiResponse.error(500, "商品添加失败: " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<MerchantProductResponse> updateProduct(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestParam("title") String title,
            @RequestParam("category") String category,
            @RequestParam("price") BigDecimal price,
            @RequestParam("stock") Integer stock,
            @RequestParam("description") String description,
            @RequestParam(value = "coverImage", required = false) MultipartFile coverImage,
            @RequestParam(value = "features", required = false) String features,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "detailImages", required = false) List<MultipartFile> detailImages,
            @RequestParam(value = "existingDetailImages", required = false) List<String> existingDetailImages) {

        Integer merchantId = (Integer) request.getAttribute("userId");

        try {
            // 构建请求对象
            MerchantProductRequest productRequest = new MerchantProductRequest();
            productRequest.setTitle(title);
            productRequest.setCategory(category);
            productRequest.setPrice(price);
            productRequest.setStock(stock);
            productRequest.setDescription(description);
            productRequest.setFeatures(features);
            if (status != null) {
                productRequest.setStatus(Product.ProductStatus.valueOf(status.toUpperCase()));
            }

            // 如果有新封面图片则上传
            if (coverImage != null && !coverImage.isEmpty()) {
                String coverUrl = fileUploadService.uploadImage(coverImage, "product-cover");
                productRequest.setCoverUrl(coverUrl);
            }

            // 合并已有图片和新上传的图片
            List<String> detailImageUrls = new java.util.ArrayList<>();

            // 先添加已存在的图片URL
            if (existingDetailImages != null && !existingDetailImages.isEmpty()) {
                detailImageUrls.addAll(existingDetailImages);
            }

            // 再上传并添加新图片
            if (detailImages != null && !detailImages.isEmpty()) {
                for (MultipartFile image : detailImages) {
                    if (!image.isEmpty()) {
                        String imageUrl = fileUploadService.uploadImage(image, "product-detail");
                        detailImageUrls.add(imageUrl);
                    }
                }
            }

            // 只有当有图片（已有或新上传）时才设置详情图片列表
            if (!detailImageUrls.isEmpty()) {
                productRequest.setDetailImages(detailImageUrls);
            }

            MerchantProductResponse response = merchantProductService.updateProduct(merchantId, id, productRequest);
            return ApiResponse.success(response);
        } catch (Exception e) {
            return ApiResponse.error(500, "商品更新失败: " + e.getMessage());
        }
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
