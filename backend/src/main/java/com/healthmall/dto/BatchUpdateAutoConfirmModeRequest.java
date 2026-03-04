package com.healthmall.dto;

import com.healthmall.entity.Product;
import java.util.List;

public class BatchUpdateAutoConfirmModeRequest {
    private List<Integer> productIds;
    private Product.AutoConfirmMode autoConfirmMode;

    public List<Integer> getProductIds() {
        return productIds;
    }

    public void setProductIds(List<Integer> productIds) {
        this.productIds = productIds;
    }

    public Product.AutoConfirmMode getAutoConfirmMode() {
        return autoConfirmMode;
    }

    public void setAutoConfirmMode(Product.AutoConfirmMode autoConfirmMode) {
        this.autoConfirmMode = autoConfirmMode;
    }
}
