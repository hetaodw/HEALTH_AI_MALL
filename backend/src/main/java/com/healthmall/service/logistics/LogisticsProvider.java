package com.healthmall.service.logistics;

import com.healthmall.dto.cainiao.CainiaoPackageData;
import com.healthmall.dto.cainiao.CainiaoResponse;

public interface LogisticsProvider {
    
    String getProviderCode();
    
    String getProviderName();
    
    void subscribePackage(String trackingNo, String phone);
    
    CainiaoResponse handleCallback(CainiaoPackageData packageData);
    
    boolean isAvailable();
}
