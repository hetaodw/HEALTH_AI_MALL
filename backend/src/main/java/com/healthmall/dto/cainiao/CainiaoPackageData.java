package com.healthmall.dto.cainiao;

import java.util.Map;

public class CainiaoPackageData {
    
    private String cpCode;
    private String logisticsStatus;
    private String subPhone;
    private String mailNo;
    private String logisticsStatusDesc;
    private String lastLogisticDetail;
    private String logisticsGmtModified;
    private Map<String, Object> packageDynmap;
    private String city;
    private String type;
    private String bizKey;
    
    public String getCpCode() {
        return cpCode;
    }
    
    public void setCpCode(String cpCode) {
        this.cpCode = cpCode;
    }
    
    public String getLogisticsStatus() {
        return logisticsStatus;
    }
    
    public void setLogisticsStatus(String logisticsStatus) {
        this.logisticsStatus = logisticsStatus;
    }
    
    public String getSubPhone() {
        return subPhone;
    }
    
    public void setSubPhone(String subPhone) {
        this.subPhone = subPhone;
    }
    
    public String getMailNo() {
        return mailNo;
    }
    
    public void setMailNo(String mailNo) {
        this.mailNo = mailNo;
    }
    
    public String getLogisticsStatusDesc() {
        return logisticsStatusDesc;
    }
    
    public void setLogisticsStatusDesc(String logisticsStatusDesc) {
        this.logisticsStatusDesc = logisticsStatusDesc;
    }
    
    public String getLastLogisticDetail() {
        return lastLogisticDetail;
    }
    
    public void setLastLogisticDetail(String lastLogisticDetail) {
        this.lastLogisticDetail = lastLogisticDetail;
    }
    
    public String getLogisticsGmtModified() {
        return logisticsGmtModified;
    }
    
    public void setLogisticsGmtModified(String logisticsGmtModified) {
        this.logisticsGmtModified = logisticsGmtModified;
    }
    
    public Map<String, Object> getPackageDynmap() {
        return packageDynmap;
    }
    
    public void setPackageDynmap(Map<String, Object> packageDynmap) {
        this.packageDynmap = packageDynmap;
    }
    
    public String getCity() {
        return city;
    }
    
    public void setCity(String city) {
        this.city = city;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getBizKey() {
        return bizKey;
    }
    
    public void setBizKey(String bizKey) {
        this.bizKey = bizKey;
    }
}
