package com.healthmall.service;

import com.healthmall.dto.MerchantProductRequest;
import com.healthmall.dto.MerchantProductResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.dto.BatchUpdateAutoConfirmModeRequest;
import com.healthmall.dto.BatchUpdateResponse;
import com.healthmall.entity.Product;
import com.healthmall.entity.ProductDetailsImage;
import com.healthmall.entity.User;
import com.healthmall.repository.ProductDetailsImageRepository;
import com.healthmall.repository.ProductRepository;
import com.healthmall.repository.UserRepository;
import com.healthmall.constants.ProductCategory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MerchantProductService {

    private static final Logger logger = LoggerFactory.getLogger(MerchantProductService.class);

    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final ProductDetailsImageRepository productDetailsImageRepository;

    public MerchantProductService(ProductRepository productRepository, UserRepository userRepository, ProductDetailsImageRepository productDetailsImageRepository) {
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.productDetailsImageRepository = productDetailsImageRepository;
    }

    @Transactional
    public MerchantProductResponse addProduct(Integer merchantId, MerchantProductRequest request) {
        logger.info("Adding product - merchantId: {}, request: {}", merchantId, request);
        
        User merchant = userRepository.findById(merchantId)
                .orElseThrow(() -> new RuntimeException("商家不存在"));

        if (merchant.getRole() != User.Role.MERCHANT) {
            throw new RuntimeException("只有商家才能添加商品");
        }

        if (!ProductCategory.isValidCategory(request.getCategory())) {
            throw new RuntimeException("无效的商品分类");
        }

        Product product = new Product();
        product.setMerchantId(merchantId);
        product.setTitle(request.getTitle());
        product.setCategory(request.getCategory());
        product.setDescription(request.getDescription());
        product.setCoverUrl(request.getCoverUrl());
        product.setDescriptionContent(request.getDescriptionContent());
        
        String features = request.getFeatures();
        if (features != null && !features.trim().isEmpty()) {
            try {
                com.alibaba.fastjson2.JSON.parse(features);
                product.setFeatures(features);
            } catch (Exception e) {
                product.setFeatures(null);
            }
        } else {
            product.setFeatures(null);
        }
        
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        product.setSales(0);
        product.setStatus(request.getStatus() != null ? request.getStatus() : Product.ProductStatus.ON_SALE);
        product.setAutoConfirmMode(request.getAutoConfirmMode() != null ? request.getAutoConfirmMode() : Product.AutoConfirmMode.MANUAL);
        product.setAutoConfirmCondition(request.getAutoConfirmCondition());

        Product savedProduct = productRepository.save(product);
        
        // 保存详细图片
        if (request.getDetailImages() != null && !request.getDetailImages().isEmpty()) {
            int sortOrder = 0;
            for (String imageUrl : request.getDetailImages()) {
                ProductDetailsImage detailImage = new ProductDetailsImage();
                detailImage.setProductId(savedProduct.getId());
                detailImage.setImageUrl(imageUrl);
                detailImage.setSortOrder(sortOrder++);
                productDetailsImageRepository.save(detailImage);
            }
        }
        
        return convertToResponse(savedProduct);
    }

    @Transactional
    public MerchantProductResponse updateProduct(Integer merchantId, Integer productId, MerchantProductRequest request) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        if (!product.getMerchantId().equals(merchantId)) {
            throw new RuntimeException("无权修改此商品");
        }

        if (!ProductCategory.isValidCategory(request.getCategory())) {
            throw new RuntimeException("无效的商品分类");
        }

        product.setTitle(request.getTitle());
        product.setCategory(request.getCategory());
        product.setDescription(request.getDescription());
        product.setDescriptionContent(request.getDescriptionContent());
        // 只有传入新的coverUrl时才更新，否则保留原值
        if (request.getCoverUrl() != null && !request.getCoverUrl().isEmpty()) {
            product.setCoverUrl(request.getCoverUrl());
        }
        
        String features = request.getFeatures();
        if (features != null && !features.trim().isEmpty()) {
            try {
                com.alibaba.fastjson2.JSON.parse(features);
                product.setFeatures(features);
            } catch (Exception e) {
                product.setFeatures(null);
            }
        } else {
            product.setFeatures(null);
        }
        
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        if (request.getStatus() != null) {
            product.setStatus(request.getStatus());
        }
        if (request.getAutoConfirmMode() != null) {
            product.setAutoConfirmMode(request.getAutoConfirmMode());
        }
        product.setAutoConfirmCondition(request.getAutoConfirmCondition());

        Product updatedProduct = productRepository.save(product);
        
        // 更新详细图片 - 先删除旧的，再添加新的
        if (request.getDetailImages() != null) {
            // 删除旧的详细图片
            List<ProductDetailsImage> oldImages = productDetailsImageRepository.findByProductIdOrderBySortOrderAsc(productId);
            productDetailsImageRepository.deleteAll(oldImages);
            
            // 添加新的详细图片
            if (!request.getDetailImages().isEmpty()) {
                int sortOrder = 0;
                for (String imageUrl : request.getDetailImages()) {
                    ProductDetailsImage detailImage = new ProductDetailsImage();
                    detailImage.setProductId(productId);
                    detailImage.setImageUrl(imageUrl);
                    detailImage.setSortOrder(sortOrder++);
                    productDetailsImageRepository.save(detailImage);
                }
            }
        }
        
        return convertToResponse(updatedProduct);
    }

    @Transactional
    public void deleteProduct(Integer merchantId, Integer productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        if (!product.getMerchantId().equals(merchantId)) {
            throw new RuntimeException("无权删除此商品");
        }

        productRepository.delete(product);
    }

    public MerchantProductResponse getProduct(Integer merchantId, Integer productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        if (!product.getMerchantId().equals(merchantId)) {
            throw new RuntimeException("无权查看此商品");
        }

        return convertToResponse(product);
    }

    public PageResponse<MerchantProductResponse> getMerchantProductsByStatus(Integer merchantId, Product.ProductStatus status, Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Product> productPage = productRepository.findByMerchantIdAndStatus(merchantId, status, pageable);

        List<MerchantProductResponse> productList = productPage.getContent().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(productList, productPage.getTotalElements());
    }

    public PageResponse<MerchantProductResponse> getMerchantProductsByCategory(Integer merchantId, String category, Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Product> productPage = productRepository.findByMerchantIdAndCategory(merchantId, category, pageable);

        List<MerchantProductResponse> productList = productPage.getContent().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(productList, productPage.getTotalElements());
    }

    public PageResponse<MerchantProductResponse> getMerchantProducts(Integer merchantId, Integer page, Integer pageSize, String status, String category) {
        Pageable pageable = PageRequest.of(page - 1, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Product> productPage;

        if (status != null && !status.isEmpty() && category != null && !category.isEmpty()) {
            Product.ProductStatus productStatus = Product.ProductStatus.valueOf(status.toUpperCase());
            productPage = productRepository.findByMerchantIdAndStatus(merchantId, productStatus, pageable);
        } else if (status != null && !status.isEmpty()) {
            Product.ProductStatus productStatus = Product.ProductStatus.valueOf(status.toUpperCase());
            productPage = productRepository.findByMerchantIdAndStatus(merchantId, productStatus, pageable);
        } else if (category != null && !category.isEmpty()) {
            productPage = productRepository.findByMerchantIdAndCategory(merchantId, category, pageable);
        } else {
            productPage = productRepository.findByMerchantId(merchantId, pageable);
        }

        List<MerchantProductResponse> productList = productPage.getContent().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());

        return new PageResponse<>(productList, productPage.getTotalElements());
    }

    @Transactional
    public MerchantProductResponse updateProductStatus(Integer merchantId, Integer productId, Product.ProductStatus status) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        if (!product.getMerchantId().equals(merchantId)) {
            throw new RuntimeException("无权修改此商品状态");
        }

        product.setStatus(status);
        Product updatedProduct = productRepository.save(product);
        return convertToResponse(updatedProduct);
    }

    @Transactional
    public MerchantProductResponse updateProductStock(Integer merchantId, Integer productId, Integer newStock) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("商品不存在"));

        if (!product.getMerchantId().equals(merchantId)) {
            throw new RuntimeException("无权修改此商品库存");
        }

        if (newStock == null || newStock < 0) {
            throw new RuntimeException("库存不能为负数");
        }

        product.setStock(newStock);
        
        if (newStock == 0) {
            product.setStatus(Product.ProductStatus.OUT_OF_STOCK);
        } else if (product.getStatus() == Product.ProductStatus.OUT_OF_STOCK) {
            product.setStatus(Product.ProductStatus.ON_SALE);
        }

        Product updatedProduct = productRepository.save(product);
        return convertToResponse(updatedProduct);
    }

    private MerchantProductResponse convertToResponse(Product product) {
        MerchantProductResponse response = new MerchantProductResponse();
        BeanUtils.copyProperties(product, response);
        
        // 查询并设置详细图片
        List<ProductDetailsImage> detailImages = productDetailsImageRepository
                .findByProductIdOrderBySortOrderAsc(product.getId());
        List<String> imageUrls = detailImages.stream()
                .map(ProductDetailsImage::getImageUrl)
                .collect(Collectors.toList());
        response.setDetailImages(imageUrls);
        
        return response;
    }

    @Transactional
    public BatchUpdateResponse batchUpdateAutoConfirmMode(Integer merchantId, BatchUpdateAutoConfirmModeRequest request) {
        logger.info("Batch update auto-confirm mode - merchantId: {}, productIds: {}, mode: {}", 
                    merchantId, request.getProductIds(), request.getAutoConfirmMode());

        BatchUpdateResponse response = new BatchUpdateResponse();

        if (request.getProductIds() == null || request.getProductIds().isEmpty()) {
            throw new RuntimeException("商品ID列表不能为空");
        }

        if (request.getAutoConfirmMode() == null) {
            throw new RuntimeException("自动确认模式不能为空");
        }

        for (Integer productId : request.getProductIds()) {
            try {
                Product product = productRepository.findById(productId)
                        .orElse(null);

                if (product == null) {
                    response.addFailedProduct(productId, "商品不存在");
                    continue;
                }

                if (!product.getMerchantId().equals(merchantId)) {
                    response.addFailedProduct(productId, "无权修改此商品");
                    continue;
                }

                product.setAutoConfirmMode(request.getAutoConfirmMode());
                productRepository.save(product);
                response.incrementSuccess();

            } catch (Exception e) {
                logger.error("更新商品自动确认模式失败 - productId: {}", productId, e);
                response.addFailedProduct(productId, "更新失败: " + e.getMessage());
            }
        }

        logger.info("Batch update completed - success: {}, failed: {}", 
                    response.getSuccessCount(), response.getFailedCount());

        return response;
    }
}
