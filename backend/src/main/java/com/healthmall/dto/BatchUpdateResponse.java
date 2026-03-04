package com.healthmall.dto;

import java.util.List;

public class BatchUpdateResponse {
    private Integer successCount;
    private Integer failedCount;
    private List<FailedProduct> failedProducts;

    public BatchUpdateResponse() {
        this.successCount = 0;
        this.failedCount = 0;
        this.failedProducts = new java.util.ArrayList<>();
    }

    public Integer getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }

    public Integer getFailedCount() {
        return failedCount;
    }

    public void setFailedCount(Integer failedCount) {
        this.failedCount = failedCount;
    }

    public List<FailedProduct> getFailedProducts() {
        return failedProducts;
    }

    public void setFailedProducts(List<FailedProduct> failedProducts) {
        this.failedProducts = failedProducts;
    }

    public void incrementSuccess() {
        this.successCount++;
    }

    public void addFailedProduct(Integer productId, String reason) {
        this.failedCount++;
        this.failedProducts.add(new FailedProduct(productId, reason));
    }

    public static class FailedProduct {
        private Integer productId;
        private String reason;

        public FailedProduct(Integer productId, String reason) {
            this.productId = productId;
            this.reason = reason;
        }

        public Integer getProductId() {
            return productId;
        }

        public void setProductId(Integer productId) {
            this.productId = productId;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }
    }
}
