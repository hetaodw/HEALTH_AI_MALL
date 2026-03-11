package com.healthmall.dto;

import com.healthmall.entity.LogisticsInfo;

public class CreateWaybillRequest {
    
    private String orderNo;
    private LogisticsInfo.LogisticsCompany logisticsCompany;
    
    public String getOrderNo() {
        return orderNo;
    }
    
    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }
    
    public LogisticsInfo.LogisticsCompany getLogisticsCompany() {
        return logisticsCompany;
    }
    
    public void setLogisticsCompany(LogisticsInfo.LogisticsCompany logisticsCompany) {
        this.logisticsCompany = logisticsCompany;
    }
}
