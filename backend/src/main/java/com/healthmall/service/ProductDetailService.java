package com.healthmall.service;

import com.healthmall.dto.ProductDetailResponse;
import com.healthmall.entity.Product;
import com.healthmall.entity.ProductDetailsImage;
import com.healthmall.entity.User;
import com.healthmall.repository.ProductDetailsImageRepository;
import com.healthmall.repository.ProductRepository;
import com.healthmall.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 商品详情服务 - 用于商品详情页面展示
 */
@Service
public class ProductDetailService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductDetailsImageRepository productDetailsImageRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * 获取商品详情
     * @param productId 商品ID
     * @return 商品详情响应DTO
     */
    public ProductDetailResponse getProductDetail(Integer productId) {
        Optional<Product> productOpt = productRepository.findById(productId);
        if (productOpt.isEmpty()) {
            return null;
        }

        Product product = productOpt.get();
        ProductDetailResponse response = new ProductDetailResponse();
        
        // 复制基本属性
        response.setId(product.getId());
        response.setMerchantId(product.getMerchantId());
        response.setTitle(product.getTitle());
        response.setCategory(product.getCategory());
        response.setDescription(product.getDescription());
        response.setCoverUrl(product.getCoverUrl());
        response.setFeatures(product.getFeatures());
        response.setPrice(product.getPrice());
        response.setStock(product.getStock());
        response.setSales(product.getSales());
        response.setStatus(product.getStatus());
        response.setCreatedAt(product.getCreatedAt());
        
        // 获取商家信息
        if (product.getMerchantId() != null) {
            Optional<User> merchantOpt = userRepository.findById(product.getMerchantId());
            merchantOpt.ifPresent(merchant -> {
                response.setMerchantName(merchant.getUsername());
                response.setMerchantAvatar(merchant.getAvatarUrl());
            });
        }
        
        // 获取详细介绍图片
        List<ProductDetailsImage> detailImages = productDetailsImageRepository
                .findByProductIdOrderBySortOrderAsc(productId);
        List<String> imageUrls = detailImages.stream()
                .map(ProductDetailsImage::getImageUrl)
                .collect(Collectors.toList());
        response.setDetailImages(imageUrls);
        
        return response;
    }
}
