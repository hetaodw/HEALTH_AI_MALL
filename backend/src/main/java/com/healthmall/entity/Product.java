package com.healthmall.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "products")
public class Product {
    
    public enum ProductStatus {
        ON_SALE,
        OFF_SALE,
        OUT_OF_STOCK
    }

    public enum AutoConfirmMode {
        AUTO,      // 自动确认：库存充足时自动确认订单
        MANUAL,    // 手动确认：所有订单都需要商家手动确认
        SMART      // 智能确认：根据订单条件智能判断是否自动确认
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "merchant_id")
    private Integer merchantId;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 50)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "cover_url", nullable = false, length = 255)
    private String coverUrl;

    @Column(columnDefinition = "JSON")
    private String features;

    @Column(name = "description_content", columnDefinition = "TEXT")
    private String descriptionContent;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column
    private Integer stock;

    @Column
    private Integer sales = 0;

    @Column(name = "average_rating")
    private Double averageRating = 0.0;

    @Column(name = "review_count")
    private Integer reviewCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private ProductStatus status = ProductStatus.ON_SALE;

    @Enumerated(EnumType.STRING)
    @Column(name = "auto_confirm_mode", length = 20)
    private AutoConfirmMode autoConfirmMode = AutoConfirmMode.MANUAL;

    @Column(name = "auto_confirm_condition", columnDefinition = "TEXT")
    private String autoConfirmCondition;

    @Column(name = "need_regenerate_tags")
    private Boolean needRegenerateTags = false;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

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

    public Double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(Double averageRating) {
        this.averageRating = averageRating;
    }

    public Integer getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(Integer reviewCount) {
        this.reviewCount = reviewCount;
    }

    public ProductStatus getStatus() {
        return status;
    }

    public void setStatus(ProductStatus status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public AutoConfirmMode getAutoConfirmMode() {
        return autoConfirmMode;
    }

    public void setAutoConfirmMode(AutoConfirmMode autoConfirmMode) {
        this.autoConfirmMode = autoConfirmMode;
    }

    public String getAutoConfirmCondition() {
        return autoConfirmCondition;
    }

    public void setAutoConfirmCondition(String autoConfirmCondition) {
        this.autoConfirmCondition = autoConfirmCondition;
    }

    public Boolean getNeedRegenerateTags() {
        return needRegenerateTags;
    }

    public void setNeedRegenerateTags(Boolean needRegenerateTags) {
        this.needRegenerateTags = needRegenerateTags;
    }

    public java.util.List<String> getTags() {
        if (features == null || features.isEmpty()) {
            return new java.util.ArrayList<>();
        }
        try {
            return com.alibaba.fastjson2.JSON.parseArray(features, String.class);
        } catch (Exception e) {
            return new java.util.ArrayList<>();
        }
    }

    public void setTags(java.util.List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            this.features = null;
        } else {
            this.features = com.alibaba.fastjson2.JSON.toJSONString(tags);
        }
    }

    public void addTag(String tag) {
        java.util.List<String> tags = getTags();
        if (!tags.contains(tag)) {
            tags.add(tag);
            setTags(tags);
        }
    }

    public void removeTag(String tag) {
        java.util.List<String> tags = getTags();
        tags.remove(tag);
        setTags(tags);
    }
}
