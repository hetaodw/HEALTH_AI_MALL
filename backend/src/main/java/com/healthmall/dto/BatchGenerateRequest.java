package com.healthmall.dto;

import java.util.List;

public class BatchGenerateRequest {
    private List<Integer> productIds;

    public List<Integer> getProductIds() {
        return productIds;
    }

    public void setProductIds(List<Integer> productIds) {
        this.productIds = productIds;
    }
}
