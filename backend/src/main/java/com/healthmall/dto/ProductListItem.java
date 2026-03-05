package com.healthmall.dto;

import com.healthmall.entity.Product;

public class ProductListItem {
    private Integer id;
    private String title;
    private String category;
    private String description;
    private String coverUrl;
    private String features;
    private java.math.BigDecimal price;
    private Integer stock;
    private Integer sales;
    private Double averageRating;
    private Integer reviewCount;
    private java.util.List<String> tags;

    public ProductListItem(Product product) {
        this.id = product.getId();
        this.title = product.getTitle();
        this.category = product.getCategory();
        this.description = product.getDescription();
        this.coverUrl = product.getCoverUrl();
        this.features = product.getFeatures();
        this.price = product.getPrice();
        this.stock = product.getStock();
        this.sales = product.getSales();
        this.averageRating = product.getAverageRating();
        this.reviewCount = product.getReviewCount();
        this.tags = product.getTags();
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

    public java.util.List<String> getTags() {
        return tags;
    }

    public void setTags(java.util.List<String> tags) {
        this.tags = tags;
    }
}
