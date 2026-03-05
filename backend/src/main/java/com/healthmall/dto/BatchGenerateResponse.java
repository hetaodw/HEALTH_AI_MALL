package com.healthmall.dto;

import java.util.ArrayList;
import java.util.List;

public class BatchGenerateResponse {
    private int successCount;
    private int failedCount;
    private List<Integer> failedProductIds;
    private String message;

    public BatchGenerateResponse() {
        this.failedProductIds = new ArrayList<>();
    }

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public int getFailedCount() {
        return failedCount;
    }

    public void setFailedCount(int failedCount) {
        this.failedCount = failedCount;
    }

    public List<Integer> getFailedProductIds() {
        return failedProductIds;
    }

    public void setFailedProductIds(List<Integer> failedProductIds) {
        this.failedProductIds = failedProductIds;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
