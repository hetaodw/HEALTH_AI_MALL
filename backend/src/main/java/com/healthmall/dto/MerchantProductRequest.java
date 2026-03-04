package com.healthmall.dto;

import com.healthmall.entity.Product;
import java.util.List;

public class MerchantProductRequest {
    private String title;
    private String category;
    private String description;
    private String coverUrl;
    private String features;
    private String descriptionContent;
    private java.math.BigDecimal price;
    private Integer stock;
    private Product.ProductStatus status;
    private List<String> detailImages;
    private Product.AutoConfirmMode autoConfirmMode;
    private String autoConfirmCondition;

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

    public String getDescriptionContent() {
        return descriptionContent;
    }

    public void setDescriptionContent(String descriptionContent) {
        this.descriptionContent = descriptionContent;
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

    public Product.ProductStatus getStatus() {
        return status;
    }

    public void setStatus(Product.ProductStatus status) {
        this.status = status;
    }

    public List<String> getDetailImages() {
        return detailImages;
    }

    public void setDetailImages(List<String> detailImages) {
        this.detailImages = detailImages;
    }

    public Product.AutoConfirmMode getAutoConfirmMode() {
        return autoConfirmMode;
    }

    public void setAutoConfirmMode(Product.AutoConfirmMode autoConfirmMode) {
        this.autoConfirmMode = autoConfirmMode;
    }

    public String getAutoConfirmCondition() {
        return autoConfirmCondition;
    }

    public void setAutoConfirmCondition(String autoConfirmCondition) {
        this.autoConfirmCondition = autoConfirmCondition;
    }
}
