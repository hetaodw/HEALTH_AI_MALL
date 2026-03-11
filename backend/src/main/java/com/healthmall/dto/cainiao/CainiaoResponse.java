package com.healthmall.dto.cainiao;

public class CainiaoResponse {
    
    private Boolean success;
    private String errorCode;
    private String errorMsg;
    
    public Boolean getSuccess() {
        return success;
    }
    
    public void setSuccess(Boolean success) {
        this.success = success;
    }
    
    public String getErrorCode() {
        return errorCode;
    }
    
    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }
    
    public String getErrorMsg() {
        return errorMsg;
    }
    
    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
    }
    
    public static CainiaoResponse success() {
        CainiaoResponse response = new CainiaoResponse();
        response.setSuccess(true);
        return response;
    }
    
    public static CainiaoResponse error(String errorCode, String errorMsg) {
        CainiaoResponse response = new CainiaoResponse();
        response.setSuccess(false);
        response.setErrorCode(errorCode);
        response.setErrorMsg(errorMsg);
        return response;
    }
}
