package com.healthmall.dto;

import com.healthmall.entity.Product;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 商品详情响应DTO - 用于商品详情页面展示
 * 包含完整商品信息、详细介绍图片等
 */
public class ProductDetailResponse {
    private Integer id;
    private Integer merchantId;
    private String merchantName;
    private String merchantAvatar;
    private String title;
    private String category;
    private String description;
    private String coverUrl;
    private String features;
    private BigDecimal price;
    private Integer stock;
    private Integer sales;
    private Product.ProductStatus status;
    private LocalDateTime createdAt;
    private List<String> detailImages;

    public ProductDetailResponse() {
    }

    public ProductDetailResponse(Product product, List<String> detailImages) {
        this.id = product.getId();
        this.merchantId = product.getMerchantId();
        this.title = product.getTitle();
        this.category = product.getCategory();
        this.description = product.getDescription();
        this.coverUrl = product.getCoverUrl();
        this.features = product.getFeatures();
        this.price = product.getPrice();
        this.stock = product.getStock();
        this.sales = product.getSales();
        this.status = product.getStatus();
        this.createdAt = product.getCreatedAt();
        this.detailImages = detailImages;
    }

    // Getters and Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(Integer merchantId) {
        this.merchantId = merchantId;
    }

    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getMerchantAvatar() {
        return merchantAvatar;
    }

    public void setMerchantAvatar(String merchantAvatar) {
        this.merchantAvatar = merchantAvatar;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public String getFeatures() {
        return features;
    }

    public void setFeatures(String features) {
        this.features = features;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public Integer getSales() {
        return sales;
    }

    public void setSales(Integer sales) {
        this.sales = sales;
    }

    public Product.ProductStatus getStatus() {
        return status;
    }

    public void setStatus(Product.ProductStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<String> getDetailImages() {
        return detailImages;
    }

    public void setDetailImages(List<String> detailImages) {
        this.detailImages = detailImages;
    }
}
