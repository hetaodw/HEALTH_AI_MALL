package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.cainiao.CainiaoPackageData;
import com.healthmall.dto.cainiao.CainiaoRequest;
import com.healthmall.dto.cainiao.CainiaoResponse;
import com.healthmall.service.LogisticsProviderManager;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

@RestController
@RequestMapping("/cainiao")
public class CainiaoController {
    
    private static final Logger logger = LoggerFactory.getLogger(CainiaoController.class);
    
    @Autowired
    private LogisticsProviderManager logisticsProviderManager;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @PostMapping("/callback")
    public CainiaoResponse handleCainiaoCallback(@RequestBody CainiaoRequest request) {
        try {
            logger.info("Received logistics callback: msgType={}, msgId={}", 
                request.getMsgType(), request.getMsgId());
            
            String receivedDigest = request.getDataDigest();
            String expectedDigest = generateDataDigest(request.getLogisticsInterface());
            
            if (!receivedDigest.equalsIgnoreCase(expectedDigest)) {
                logger.error("Signature verification failed for msgId: {}", request.getMsgId());
                return CainiaoResponse.error("SIGN_ERROR", "签名验证失败");
            }
            
            CainiaoPackageData packageData = objectMapper.readValue(
                request.getLogisticsInterface(), 
                CainiaoPackageData.class
            );
            
            logger.info("Processing package update: mailNo={}, status={}", 
                packageData.getMailNo(), packageData.getLogisticsStatus());
            
            return logisticsProviderManager.handleCallback(packageData);
            
        } catch (Exception e) {
            logger.error("Error processing logistics callback", e);
            return CainiaoResponse.error("PROCESS_ERROR", e.getMessage());
        }
    }
    
    @PostMapping("/subscribe")
    public ApiResponse<String> subscribePackage(
        @RequestParam String mailNo,
        @RequestParam String subPhone
    ) {
        try {
            logisticsProviderManager.subscribePackage(mailNo, subPhone, "CAINIAO");
            return ApiResponse.success("订阅成功");
        } catch (Exception e) {
            logger.error("Error subscribing to package: {}", mailNo, e);
            return ApiResponse.error(500, e.getMessage());
        }
    }
    
    @GetMapping("/providers")
    public ApiResponse<java.util.List<String>> getAvailableProviders() {
        try {
            java.util.List<String> providers = logisticsProviderManager.getAvailableProviders();
            return ApiResponse.success(providers);
        } catch (Exception e) {
            logger.error("Error getting available providers", e);
            return ApiResponse.error(500, e.getMessage());
        }
    }
    
    private String generateDataDigest(String content) {
        try {
            String signContent = content + "YOUR_APP_SECRET";
            
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(signContent.getBytes(StandardCharsets.UTF_8));
            
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            
            return sb.toString().toUpperCase();
        } catch (Exception e) {
            logger.error("Error generating data digest", e);
            return null;
        }
    }
}
