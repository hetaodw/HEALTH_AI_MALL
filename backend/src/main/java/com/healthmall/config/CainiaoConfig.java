package com.healthmall.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "cainiao")
public class CainiaoConfig {
    
    private String appKey;
    private String appSecret;
    private String partnerCode;
    private String fromCode;
    private String gatewayUrl;
    private String sandboxUrl;
    private boolean sandboxMode = false;
    
    public String getAppKey() {
        return appKey;
    }
    
    public void setAppKey(String appKey) {
        this.appKey = appKey;
    }
    
    public String getAppSecret() {
        return appSecret;
    }
    
    public void setAppSecret(String appSecret) {
        this.appSecret = appSecret;
    }
    
    public String getPartnerCode() {
        return partnerCode;
    }
    
    public void setPartnerCode(String partnerCode) {
        this.partnerCode = partnerCode;
    }
    
    public String getFromCode() {
        return fromCode;
    }
    
    public void setFromCode(String fromCode) {
        this.fromCode = fromCode;
    }
    
    public String getGatewayUrl() {
        return gatewayUrl;
    }
    
    public void setGatewayUrl(String gatewayUrl) {
        this.gatewayUrl = gatewayUrl;
    }
    
    public String getSandboxUrl() {
        return sandboxUrl;
    }
    
    public void setSandboxUrl(String sandboxUrl) {
        this.sandboxUrl = sandboxUrl;
    }
    
    public boolean isSandboxMode() {
        return sandboxMode;
    }
    
    public void setSandboxMode(boolean sandboxMode) {
        this.sandboxMode = sandboxMode;
    }
    
    public String getActiveUrl() {
        return sandboxMode ? sandboxUrl : gatewayUrl;
    }
}
