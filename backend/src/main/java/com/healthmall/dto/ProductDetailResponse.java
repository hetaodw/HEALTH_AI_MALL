package com.healthmall.dto;

import com.healthmall.entity.Product;

public class ProductDetailResponse {
    private Integer id;
    private String title;
    private String description;
    private String coverUrl;
    private String features;
    private java.math.BigDecimal price;
    private Integer stock;
    private String createdAt;
    private java.util.List<String> detailImages;

    public ProductDetailResponse(Product product, java.util.List<String> detailImages) {
        this.id = product.getId();
        this.title = product.getTitle();
        this.description = product.getDescription();
        this.coverUrl = product.getCoverUrl();
        this.features = product.getFeatures();
        this.price = product.getPrice();
        this.stock = product.getStock();
        this.createdAt = product.getCreatedAt() != null ? product.getCreatedAt().toString() : null;
        this.detailImages = detailImages;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
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

    public java.math.BigDecimal getPrice() {
        return price;
    }

    public void setPrice(java.math.BigDecimal price) {
        this.price = price;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public java.util.List<String> getDetailImages() {
        return detailImages;
    }

    public void setDetailImages(java.util.List<String> detailImages) {
        this.detailImages = detailImages;
    }
}
