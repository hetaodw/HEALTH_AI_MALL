package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.entity.RiskControlRecord;
import com.healthmall.repository.RiskControlRepository;
import com.healthmall.service.RiskControlService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/admin/risk-control")
public class RiskControlController {
    
    @Autowired
    private RiskControlService riskControlService;
    
    @Autowired
    private RiskControlRepository riskControlRepository;
    
    @PostMapping("/orders/{orderNo}/check")
    public ApiResponse<RiskControlRecord> checkRisk(@PathVariable String orderNo) {
        RiskControlRecord record = riskControlService.checkRisk(orderNo);
        return ApiResponse.success(record);
    }
    
    @GetMapping("/orders/{orderNo}")
    public ApiResponse<RiskControlRecord> getRiskRecord(@PathVariable String orderNo) {
        RiskControlRecord record = riskControlRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new RuntimeException("风控记录不存在"));
        return ApiResponse.success(record);
    }
    
    @PostMapping("/records/{recordId}/review")
    public ApiResponse<Void> reviewRecord(
        @PathVariable Long recordId,
        @RequestParam Integer reviewerId,
        @RequestParam String comment,
        @RequestParam boolean approved
    ) {
        riskControlService.manualReview(recordId, reviewerId, comment, approved);
        return ApiResponse.success();
    }
    
    @GetMapping("/records/pending")
    public ApiResponse<List<RiskControlRecord>> getPendingRecords() {
        List<RiskControlRecord> records = riskControlRepository.findByStatusAndCreatedAtBefore(
            RiskControlRecord.RiskStatus.MANUAL_REVIEW,
            LocalDateTime.now().minusDays(7)
        );
        return ApiResponse.success(records);
    }
}
