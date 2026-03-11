package com.healthmall.service;

import com.healthmall.dto.cainiao.CainiaoPackageData;
import com.healthmall.dto.cainiao.CainiaoResponse;
import com.healthmall.service.logistics.LogisticsProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class LogisticsProviderManager {
    
    private static final Logger logger = LoggerFactory.getLogger(LogisticsProviderManager.class);
    
    private final Map<String, LogisticsProvider> providers;
    
    @Autowired
    public LogisticsProviderManager(List<LogisticsProvider> providerList) {
        this.providers = providerList.stream()
            .collect(Collectors.toMap(
                LogisticsProvider::getProviderCode,
                Function.identity()
            ));
        
        logger.info("Initialized logistics providers: {}", providers.keySet());
    }
    
    public LogisticsProvider getProvider(String providerCode) {
        LogisticsProvider provider = providers.get(providerCode);
        if (provider == null) {
            throw new IllegalArgumentException("不支持的物流提供商: " + providerCode);
        }
        return provider;
    }
    
    public LogisticsProvider getAvailableProvider() {
        for (LogisticsProvider provider : providers.values()) {
            if (provider.isAvailable()) {
                logger.info("Using available logistics provider: {}", provider.getProviderName());
                return provider;
            }
        }
        logger.warn("No available logistics provider found, using TEST provider");
        return providers.get("TEST");
    }
    
    public void subscribePackage(String trackingNo, String phone, String providerCode) {
        LogisticsProvider provider = getProvider(providerCode);
        logger.info("Subscribing to package via provider: {}, trackingNo: {}", 
            provider.getProviderName(), trackingNo);
        provider.subscribePackage(trackingNo, phone);
    }
    
    public CainiaoResponse handleCallback(CainiaoPackageData packageData) {
        String cpCode = packageData.getCpCode();
        LogisticsProvider provider = getProvider(cpCode);
        logger.info("Handling callback via provider: {}, trackingNo: {}", 
            provider.getProviderName(), packageData.getMailNo());
        return provider.handleCallback(packageData);
    }
    
    public List<String> getAvailableProviders() {
        return providers.values().stream()
            .filter(LogisticsProvider::isAvailable)
            .map(LogisticsProvider::getProviderName)
            .collect(Collectors.toList());
    }
}
