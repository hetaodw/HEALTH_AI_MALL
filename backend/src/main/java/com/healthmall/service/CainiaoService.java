package com.healthmall.service;

import com.healthmall.config.CainiaoConfig;
import com.healthmall.dto.cainiao.CainiaoPackageData;
import com.healthmall.dto.cainiao.CainiaoRequest;
import com.healthmall.dto.cainiao.CainiaoResponse;
import com.healthmall.entity.LogisticsInfo;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.LogisticsRepository;
import com.healthmall.service.logistics.LogisticsProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class CainiaoService implements LogisticsProvider {
    
    private static final Logger logger = LoggerFactory.getLogger(CainiaoService.class);
    
    private static final String MSG_TYPE = "LPC_PACK_PUB";
    
    @Autowired
    private CainiaoConfig cainiaoConfig;
    
    @Autowired
    private LogisticsRepository logisticsRepository;
    
    @Autowired(required = false)
    private RestTemplate restTemplate;
    
    @Override
    public String getProviderCode() {
        return "CAINIAO";
    }
    
    @Override
    public String getProviderName() {
        return "菜鸟物流";
    }
    
    @Override
    public void subscribePackage(String trackingNo, String phone) {
        try {
            String msgId = UUID.randomUUID().toString();
            
            CainiaoPackageData packageData = new CainiaoPackageData();
            packageData.setMailNo(trackingNo);
            packageData.setSubPhone(phone);
            packageData.setType("receive");
            packageData.setBizKey(trackingNo);
            
            String dataDigest = generateDataDigest(packageData);
            
            CainiaoRequest request = new CainiaoRequest();
            request.setMsgType(MSG_TYPE);
            request.setMsgId(msgId);
            request.setFromCode(cainiaoConfig.getFromCode());
            request.setPartnerCode(cainiaoConfig.getPartnerCode());
            request.setDataDigest(dataDigest);
            request.setLogisticsInterface(convertPackageDataToJson(packageData));
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<CainiaoRequest> entity = new HttpEntity<>(request, headers);
            
            ResponseEntity<String> response = restTemplate.postForEntity(
                cainiaoConfig.getActiveUrl(),
                entity,
                String.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK) {
                logger.info("Successfully subscribed to package: {}", trackingNo);
            } else {
                logger.error("Failed to subscribe to package: {}", trackingNo);
                throw new BusinessException(500, "订阅包裹物流信息失败");
            }
        } catch (Exception e) {
            logger.error("Error subscribing to package: {}", trackingNo, e);
            throw new BusinessException(500, "订阅包裹物流信息失败: " + e.getMessage());
        }
    }
    
    @Override
    public CainiaoResponse handleCallback(CainiaoPackageData packageData) {
        try {
            String mailNo = packageData.getMailNo();
            
            LogisticsInfo logistics = logisticsRepository.findByTrackingNo(mailNo)
                .orElseThrow(() -> {
                    logger.warn("Logistics not found for tracking no: {}", mailNo);
                    return null;
                });
            
            LogisticsInfo.LogisticsStatus newStatus = convertCainiaoStatus(packageData.getLogisticsStatus());
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
                logger.info("Successfully updated logistics for tracking no: {}, status: {}", mailNo, newStatus);
            }
            
            return CainiaoResponse.success();
        } catch (Exception e) {
            logger.error("Error handling package update: {}", packageData.getMailNo(), e);
            return CainiaoResponse.error("PROCESS_ERROR", e.getMessage());
        }
    }
    
    private String generateDataDigest(CainiaoPackageData packageData) {
        try {
            String content = convertPackageDataToJson(packageData);
            String signContent = content + cainiaoConfig.getAppSecret();
            
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(signContent.getBytes(StandardCharsets.UTF_8));
            
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            
            return sb.toString().toUpperCase();
        } catch (Exception e) {
            logger.error("Error generating data digest", e);
            throw new BusinessException(500, "生成签名失败");
        }
    }
    
    private String convertPackageDataToJson(CainiaoPackageData packageData) {
        Map<String, Object> data = new HashMap<>();
        data.put("cpCode", packageData.getCpCode());
        data.put("logisticsStatus", packageData.getLogisticsStatus());
        data.put("subPhone", packageData.getSubPhone());
        data.put("mailNo", packageData.getMailNo());
        data.put("logisticsStatusDesc", packageData.getLogisticsStatusDesc());
        data.put("lastLogisticDetail", packageData.getLastLogisticDetail());
        data.put("logisticsGmtModified", packageData.getLogisticsGmtModified());
        data.put("packageDynmap", packageData.getPackageDynmap());
        data.put("city", packageData.getCity());
        data.put("type", packageData.getType());
        data.put("bizKey", packageData.getBizKey());
        
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            if (!first) {
                json.append(",");
            }
            json.append("\"").append(entry.getKey()).append("\":");
            if (entry.getValue() == null) {
                json.append("null");
            } else if (entry.getValue() instanceof String) {
                json.append("\"").append(entry.getValue()).append("\"");
            } else {
                json.append(entry.getValue());
            }
            first = false;
        }
        json.append("}");
        
        return json.toString();
    }
    
    private LogisticsInfo.LogisticsStatus convertCainiaoStatus(String cainiaoStatus) {
        if (cainiaoStatus == null) {
            return null;
        }
        
        switch (cainiaoStatus.toUpperCase()) {
            case "SIGN":
                return LogisticsInfo.LogisticsStatus.DELIVERED;
            case "PICKED":
                return LogisticsInfo.LogisticsStatus.PICKED;
            case "IN_TRANSIT":
                return LogisticsInfo.LogisticsStatus.IN_TRANSIT;
            case "EXCEPTION":
                return LogisticsInfo.LogisticsStatus.EXCEPTION;
            default:
                logger.warn("Unknown Cainiao status: {}", cainiaoStatus);
                return null;
        }
    }
    
    @Override
    public boolean isAvailable() {
        return cainiaoConfig.getAppKey() != null && 
               !cainiaoConfig.getAppKey().equals("your-app-key") &&
               restTemplate != null;
    }
}
