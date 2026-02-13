package com.healthmall.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "product_snapshots")
public class ProductSnapshot {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_id", nullable = false)
    private Integer productId;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(length = 50)
    private String category;

    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "merchant_id")
    private Integer merchantId;

    @Column(name = "merchant_name", length = 50)
    private String merchantName;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
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

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public static ProductSnapshot fromProduct(Product product, String merchantName) {
        ProductSnapshot snapshot = new ProductSnapshot();
        snapshot.setProductId(product.getId());
        snapshot.setTitle(product.getTitle());
        snapshot.setCategory(product.getCategory());
        snapshot.setCoverUrl(product.getCoverUrl());
        snapshot.setPrice(product.getPrice());
        snapshot.setMerchantId(product.getMerchantId());
        snapshot.setMerchantName(merchantName);
        return snapshot;
    }
}
