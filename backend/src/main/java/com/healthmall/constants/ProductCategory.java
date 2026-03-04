package com.healthmall.constants;

public class ProductCategory {
    public static final String HEALTH_PRODUCTS = "HEALTH_PRODUCTS";
    public static final String MEDICAL_DEVICES = "MEDICAL_DEVICES";
    public static final String HEALTH_FOOD = "HEALTH_FOOD";
    public static final String SPORTS_FITNESS = "SPORTS_FITNESS";
    public static final String MATERNAL_BABY = "MATERNAL_BABY";

    public static final String[] ALL_CATEGORIES = {
        HEALTH_PRODUCTS,
        MEDICAL_DEVICES,
        HEALTH_FOOD,
        SPORTS_FITNESS,
        MATERNAL_BABY
    };

    public static boolean isValidCategory(String category) {
        if (category == null || category.isEmpty()) {
            return false;
        }
        for (String validCategory : ALL_CATEGORIES) {
            if (validCategory.equals(category)) {
                return true;
            }
        }
        return false;
    }
}
