package com.healthmall.dto;

import com.healthmall.entity.BrowsingHistory;
import com.healthmall.entity.Product;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class BrowsingHistoryItem {
    private Integer id;
    private Integer productId;
    private String productTitle;
    private String productCoverUrl;
    private BigDecimal productPrice;
    private LocalDateTime viewedAt;

    public BrowsingHistoryItem(BrowsingHistory bh, Product product) {
        this.id = bh.getId();
        this.productId = bh.getProductId();
        if (product != null) {
            this.productTitle = product.getTitle();
            this.productCoverUrl = product.getCoverUrl();
            this.productPrice = product.getPrice();
        }
        this.viewedAt = bh.getViewedAt();
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public String getProductTitle() {
        return productTitle;
    }

    public void setProductTitle(String productTitle) {
        this.productTitle = productTitle;
    }

    public String getProductCoverUrl() {
        return productCoverUrl;
    }

    public void setProductCoverUrl(String productCoverUrl) {
        this.productCoverUrl = productCoverUrl;
    }

    public BigDecimal getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(BigDecimal productPrice) {
        this.productPrice = productPrice;
    }

    public LocalDateTime getViewedAt() {
        return viewedAt;
    }

    public void setViewedAt(LocalDateTime viewedAt) {
        this.viewedAt = viewedAt;
    }
}
