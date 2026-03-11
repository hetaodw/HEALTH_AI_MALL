package com.healthmall.dto.cainiao;

public class CainiaoRequest {
    
    private String msgType;
    private String msgId;
    private String fromCode;
    private String partnerCode;
    private String dataDigest;
    private String logisticsInterface;
    
    public String getMsgType() {
        return msgType;
    }
    
    public void setMsgType(String msgType) {
        this.msgType = msgType;
    }
    
    public String getMsgId() {
        return msgId;
    }
    
    public void setMsgId(String msgId) {
        this.msgId = msgId;
    }
    
    public String getFromCode() {
        return fromCode;
    }
    
    public void setFromCode(String fromCode) {
        this.fromCode = fromCode;
    }
    
    public String getPartnerCode() {
        return partnerCode;
    }
    
    public void setPartnerCode(String partnerCode) {
        this.partnerCode = partnerCode;
    }
    
    public String getDataDigest() {
        return dataDigest;
    }
    
    public void setDataDigest(String dataDigest) {
        this.dataDigest = dataDigest;
    }
    
    public String getLogisticsInterface() {
        return logisticsInterface;
    }
    
    public void setLogisticsInterface(String logisticsInterface) {
        this.logisticsInterface = logisticsInterface;
    }
}
