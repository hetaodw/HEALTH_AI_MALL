package com.healthmall.service;

import com.healthmall.dto.PageResponse;
import com.healthmall.dto.ProductDetailResponse;
import com.healthmall.dto.ProductListItem;
import com.healthmall.entity.Product;
import com.healthmall.entity.ProductDescription;
import com.healthmall.entity.ProductDetailsImage;
import com.healthmall.entity.ProductReview;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductDescriptionRepository;
import com.healthmall.repository.ProductDetailsImageRepository;
import com.healthmall.repository.ProductRepository;
import com.healthmall.repository.ProductReviewRepository;
import com.healthmall.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductDetailsImageRepository productDetailsImageRepository;

    @Autowired
    private ProductDescriptionRepository productDescriptionRepository;

    @Autowired
    private ProductReviewRepository productReviewRepository;

    @Autowired
    private UserRepository userRepository;

    public PageResponse<ProductListItem> getProductList(Integer page, Integer size, Boolean isHot,
                                                         String category, BigDecimal minPrice,
                                                         BigDecimal maxPrice, String sortBy,
                                                         String sortOrder) {
        Sort sort = Sort.by("createdAt").descending();

        if (sortBy != null && !sortBy.isEmpty()) {
            Sort.Direction direction = "desc".equalsIgnoreCase(sortOrder) ? Sort.Direction.DESC : Sort.Direction.ASC;
            sort = Sort.by(direction, sortBy);
        }

        Pageable pageable = PageRequest.of(page - 1, size, sort);
        Page<Product> productPage;

        if (isHot != null && isHot) {
            List<Product> hotProducts = productRepository.findHotProducts(pageable);
            productPage = new org.springframework.data.domain.PageImpl<>(
                    hotProducts,
                    pageable,
                    hotProducts.size()
            );
        } else {
            productPage = productRepository.findProducts(category, minPrice, maxPrice, pageable);
        }

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }

    public PageResponse<ProductListItem> searchProducts(String keyword, BigDecimal minPrice,
                                                          BigDecimal maxPrice, String sortBy,
                                                          Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Product> productPage = productRepository.searchProducts(keyword, minPrice, maxPrice, pageable);

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }

    public List<ProductListItem> getHotProducts(Integer limit) {
        Pageable pageable = PageRequest.of(0, limit);
        List<Product> hotProducts = productRepository.findHotProducts(pageable);
        return hotProducts.stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());
    }

    public ProductDetailResponse getProductDetail(Integer id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        List<ProductDetailsImage> detailImages = productDetailsImageRepository
                .findByProductIdOrderBySortOrderAsc(id);

        List<String> imageUrls = detailImages.stream()
                .map(ProductDetailsImage::getImageUrl)
                .collect(Collectors.toList());

        ProductDetailResponse response = new ProductDetailResponse(product, imageUrls);
        
        // 查询并设置商家名称和头像
        if (product.getMerchantId() != null) {
            userRepository.findById(product.getMerchantId())
                    .ifPresent(user -> {
                        response.setMerchantName(user.getUsername());
                        response.setMerchantAvatar(user.getAvatarUrl());
                    });
        }
        
        // 查询并设置商品详情介绍
        productDescriptionRepository.findByProductId(id)
                .ifPresent(description -> response.setDescriptionContent(description.getContent()));
        
        // 查询并设置评分统计
        Double averageRating = productReviewRepository.findAverageRatingByProductId(id, ProductReview.ReviewStatus.APPROVED);
        Long reviewCount = productReviewRepository.countByProductIdAndStatus(id, ProductReview.ReviewStatus.APPROVED);
        response.setAverageRating(averageRating != null ? averageRating : 0.0);
        response.setReviewCount(reviewCount != null ? reviewCount.intValue() : 0);
        
        return response;
    }

    public Integer createProduct(String name, String category, BigDecimal price,
                                 Integer stock, String description, String coverUrl, String features) {
        Product product = new Product();
        product.setTitle(name);
        product.setCategory(category);
        product.setPrice(price);
        product.setStock(stock);
        product.setDescription(description);
        product.setCoverUrl(coverUrl != null ? coverUrl : "https://via.placeholder.com/300");
        product.setFeatures(features);

        Product savedProduct = productRepository.save(product);
        return savedProduct.getId();
    }

    public PageResponse<ProductListItem> getProductsByCategory(String category, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Product> productPage = productRepository.findByCategory(category, pageable);

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }
}
