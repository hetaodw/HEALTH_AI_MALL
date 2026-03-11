package com.healthmall.service.logistics.impl;

import com.healthmall.dto.cainiao.CainiaoPackageData;
import com.healthmall.dto.cainiao.CainiaoResponse;
import com.healthmall.entity.LogisticsInfo;
import com.healthmall.repository.LogisticsRepository;
import com.healthmall.service.logistics.LogisticsProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class TestLogisticsProvider implements LogisticsProvider {
    
    private static final Logger logger = LoggerFactory.getLogger(TestLogisticsProvider.class);
    
    @Autowired
    private LogisticsRepository logisticsRepository;
    
    @Override
    public String getProviderCode() {
        return "TEST";
    }
    
    @Override
    public String getProviderName() {
        return "测试物流公司";
    }
    
    @Override
    public void subscribePackage(String trackingNo, String phone) {
        logger.info("Test Logistics: Subscribing to package trackingNo={}, phone={}", trackingNo, phone);
        
        try {
            LogisticsInfo logistics = logisticsRepository.findByTrackingNo(trackingNo)
                .orElseThrow(() -> new RuntimeException("物流信息不存在"));
            
            logistics.setCainiaoSubscribed(true);
            logistics.setCainiaoLastUpdate(LocalDateTime.now());
            
            String initialTrace = String.format("[%s] 包裹已创建，等待揽收", 
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            logistics.setTraceInfo(initialTrace);
            
            logisticsRepository.save(logistics);
            
            logger.info("Test Logistics: Successfully subscribed to package {}", trackingNo);
        } catch (Exception e) {
            logger.error("Test Logistics: Failed to subscribe to package {}", trackingNo, e);
            throw new RuntimeException("订阅测试物流失败", e);
        }
    }
    
    @Override
    public CainiaoResponse handleCallback(CainiaoPackageData packageData) {
        logger.info("Test Logistics: Received callback for trackingNo={}, status={}", 
            packageData.getMailNo(), packageData.getLogisticsStatus());
        
        try {
            String trackingNo = packageData.getMailNo();
            
            LogisticsInfo logistics = logisticsRepository.findByTrackingNo(trackingNo)
                .orElseThrow(() -> {
                    logger.warn("Test Logistics: Logistics not found for tracking no: {}", trackingNo);
                    return null;
                });
            
            LogisticsInfo.LogisticsStatus newStatus = convertTestStatus(packageData.getLogisticsStatus());
            if (newStatus != null) {
                logistics.setStatus(newStatus);
                
                if (newStatus == LogisticsInfo.LogisticsStatus.DELIVERED) {
                    logistics.setDeliveredAt(LocalDateTime.now());
                }
                
                logistics.setCainiaoSubscribed(true);
                logistics.setCainiaoLastUpdate(LocalDateTime.now());
                
                String traceInfo = packageData.getLastLogisticDetail();
                if (traceInfo != null && !traceInfo.isEmpty()) {
                    String existingTrace = logistics.getTraceInfo();
                    String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                    String newTrace = String.format("[%s] %s", timestamp, traceInfo);
                    
                    if (existingTrace != null && !existingTrace.isEmpty()) {
                        logistics.setTraceInfo(newTrace + "\n" + existingTrace);
                    } else {
                        logistics.setTraceInfo(newTrace);
                    }
                }
                
                logisticsRepository.save(logistics);
                logger.info("Test Logistics: Successfully updated logistics for tracking no: {}, status: {}", 
                    trackingNo, newStatus);
            }
            
            return CainiaoResponse.success();
        } catch (Exception e) {
            logger.error("Test Logistics: Error handling callback for tracking no: {}", 
                packageData.getMailNo(), e);
            return CainiaoResponse.error("PROCESS_ERROR", e.getMessage());
        }
    }
    
    @Override
    public boolean isAvailable() {
        return true;
    }
    
    private LogisticsInfo.LogisticsStatus convertTestStatus(String testStatus) {
        if (testStatus == null) {
            return null;
        }
        
        switch (testStatus.toUpperCase()) {
            case "SIGN":
            case "DELIVERED":
                return LogisticsInfo.LogisticsStatus.DELIVERED;
            case "PICKED":
                return LogisticsInfo.LogisticsStatus.PICKED;
            case "IN_TRANSIT":
                return LogisticsInfo.LogisticsStatus.IN_TRANSIT;
            case "EXCEPTION":
                return LogisticsInfo.LogisticsStatus.EXCEPTION;
            case "CREATED":
                return LogisticsInfo.LogisticsStatus.CREATED;
            default:
                logger.warn("Test Logistics: Unknown status: {}", testStatus);
                return null;
        }
    }
}
