package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.CreateWaybillRequest;
import com.healthmall.entity.LogisticsInfo;
import com.healthmall.service.LogisticsService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/merchant/logistics")
public class LogisticsController {
    
    @Autowired
    private LogisticsService logisticsService;
    
    @PostMapping("/waybill")
    public ApiResponse<LogisticsInfo> createWaybill(
        @RequestBody CreateWaybillRequest request,
        HttpServletRequest httpRequest
    ) {
        Integer merchantId = (Integer) httpRequest.getAttribute("userId");
        if (merchantId == null) {
            return ApiResponse.error(401, "请先登录");
        }
        
        LogisticsInfo logistics = logisticsService.createWaybill(
            request.getOrderNo(), 
            request.getLogisticsCompany(),
            merchantId
        );
        return ApiResponse.success(logistics);
    }
    
    @GetMapping("/{orderNo}")
    public ApiResponse<LogisticsInfo> getLogisticsInfo(@PathVariable String orderNo) {
        LogisticsInfo logistics = logisticsService.getLogisticsInfo(orderNo);
        return ApiResponse.success(logistics);
    }
}
