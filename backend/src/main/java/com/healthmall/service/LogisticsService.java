package com.healthmall.service;

import com.healthmall.entity.LogisticsInfo;
import com.healthmall.entity.Order;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.LogisticsRepository;
import com.healthmall.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class LogisticsService {
    
    @Autowired
    private LogisticsRepository logisticsRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private LogisticsProviderManager logisticsProviderManager;
    
    public LogisticsInfo createWaybill(String orderNo, LogisticsInfo.LogisticsCompany company) {
        Order order = orderRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new BusinessException(404, "订单不存在"));
        
        if (order.getStatus() != Order.OrderStatus.PAID) {
            throw new BusinessException(400, "订单状态不允许发货");
        }
        
        String trackingNo = applyWaybillFromLogisticsCompany(order, company);
        String waybillUrl = generateWaybillUrl(trackingNo, company);
        
        LogisticsInfo logistics = new LogisticsInfo();
        logistics.setOrderNo(orderNo);
        logistics.setLogisticsCompany(company);
        logistics.setTrackingNo(trackingNo);
        logistics.setWaybillUrl(waybillUrl);
        logistics.setStatus(LogisticsInfo.LogisticsStatus.CREATED);
        logistics.setEstimatedDelivery(LocalDateTime.now().plusDays(3));
        
        LogisticsInfo savedLogistics = logisticsRepository.save(logistics);
        
        try {
            String providerCode = convertToProviderCode(company);
            logisticsProviderManager.subscribePackage(trackingNo, order.getReceiverPhone(), providerCode);
        } catch (Exception e) {
            System.err.println("Failed to subscribe to logistics provider: " + e.getMessage());
        }
        
        return savedLogistics;
    }
    
    private String convertToProviderCode(LogisticsInfo.LogisticsCompany company) {
        switch (company) {
            case TEST:
                return "TEST";
            case YTO:
                return "CAINIAO";
            case SF:
            case STO:
            case ZTO:
            case EMS:
            default:
                return "CAINIAO";
        }
    }
    
    private String applyWaybillFromLogisticsCompany(Order order, LogisticsInfo.LogisticsCompany company) {
        switch (company) {
            case TEST:
                return applyTestWaybill(order);
            case SF:
                return applySfWaybill(order);
            case STO:
                return applyStoWaybill(order);
            case YTO:
                return applyYtoWaybill(order);
            case ZTO:
                return applyZtoWaybill(order);
            case EMS:
                return applyEmsWaybill(order);
            default:
                throw new BusinessException(400, "不支持的物流公司");
        }
    }
    
    private String applyTestWaybill(Order order) {
        return "TEST" + System.currentTimeMillis();
    }
    
    private String applySfWaybill(Order order) {
        return "SF" + System.currentTimeMillis();
    }
    
    private String applyStoWaybill(Order order) {
        return "STO" + System.currentTimeMillis();
    }
    
    private String applyYtoWaybill(Order order) {
        return "YTO" + System.currentTimeMillis();
    }
    
    private String applyZtoWaybill(Order order) {
        return "ZTO" + System.currentTimeMillis();
    }
    
    private String applyEmsWaybill(Order order) {
        return "EMS" + System.currentTimeMillis();
    }
    
    private String generateWaybillUrl(String trackingNo, LogisticsInfo.LogisticsCompany company) {
        return String.format("https://www.%s.com/waybill/%s", 
            company.name().toLowerCase(), trackingNo);
    }
    
    public LogisticsInfo getLogisticsInfo(String orderNo) {
        return logisticsRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new BusinessException(404, "物流信息不存在"));
    }
    
    public void updateLogisticsStatus(String orderNo, LogisticsInfo.LogisticsStatus status) {
        LogisticsInfo logistics = logisticsRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new BusinessException(404, "物流信息不存在"));
        
        logistics.setStatus(status);
        
        if (status == LogisticsInfo.LogisticsStatus.DELIVERED) {
            logistics.setDeliveredAt(LocalDateTime.now());
        }
        
        logisticsRepository.save(logistics);
    }
}
