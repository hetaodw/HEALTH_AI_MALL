package com.healthmall.dto;

import com.healthmall.entity.LogisticsInfo;

public class ShipOrderRequest {
    
    private String orderNo;
    private String trackingNo;
    private LogisticsInfo.LogisticsCompany logisticsCompany;
    
    public String getOrderNo() {
        return orderNo;
    }
    
    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }
    
    public String getTrackingNo() {
        return trackingNo;
    }
    
    public void setTrackingNo(String trackingNo) {
        this.trackingNo = trackingNo;
    }
    
    public LogisticsInfo.LogisticsCompany getLogisticsCompany() {
        return logisticsCompany;
    }
    
    public void setLogisticsCompany(LogisticsInfo.LogisticsCompany logisticsCompany) {
        this.logisticsCompany = logisticsCompany;
    }
}
