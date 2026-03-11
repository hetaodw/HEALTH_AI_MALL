package com.healthmall.service;

import com.healthmall.entity.Order;
import com.healthmall.entity.RiskControlRecord;
import com.healthmall.entity.User;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.OrderRepository;
import com.healthmall.repository.RiskControlRepository;
import com.healthmall.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class RiskControlService {
    
    @Autowired
    private RiskControlRepository riskControlRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    private static final int HIGH_AMOUNT_THRESHOLD = 10000;
    private static final int FREQUENT_ORDER_THRESHOLD = 5;
    
    public RiskControlRecord checkRisk(String orderNo) {
        Order order = orderRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new BusinessException(404, "订单不存在"));
        
        RiskControlRecord record = new RiskControlRecord();
        record.setOrderNo(orderNo);
        record.setUserId(order.getUserId());
        
        int riskScore = 0;
        List<String> riskReasons = new ArrayList<>();
        
        User user = userRepository.findById(order.getUserId()).orElse(null);
        
        if (order.getTotalAmount().compareTo(BigDecimal.valueOf(HIGH_AMOUNT_THRESHOLD)) > 0) {
            riskScore += 30;
            riskReasons.add("订单金额超过阈值");
        }
        
        if (user != null && user.getRole() == User.Role.BLACKLIST) {
            riskScore += 100;
            riskReasons.add("用户在黑名单");
        }
        
        long recentOrderCount = orderRepository.findByUserIdOrderByCreatedAtDesc(order.getUserId())
            .stream()
            .filter(o -> o.getCreatedAt().isAfter(LocalDateTime.now().minusHours(1)))
            .count();
        
        if (recentOrderCount >= FREQUENT_ORDER_THRESHOLD) {
            riskScore += 20;
            riskReasons.add("频繁下单");
        }
        
        record.setRiskScore(riskScore);
        record.setRiskReason(String.join("; ", riskReasons));
        
        if (riskScore >= 80) {
            record.setRiskLevel(RiskControlRecord.RiskLevel.CRITICAL);
            record.setStatus(RiskControlRecord.RiskStatus.MANUAL_REVIEW);
        } else if (riskScore >= 50) {
            record.setRiskLevel(RiskControlRecord.RiskLevel.HIGH);
            record.setStatus(RiskControlRecord.RiskStatus.MANUAL_REVIEW);
        } else if (riskScore >= 20) {
            record.setRiskLevel(RiskControlRecord.RiskLevel.MEDIUM);
            record.setStatus(RiskControlRecord.RiskStatus.APPROVED);
        } else {
            record.setRiskLevel(RiskControlRecord.RiskLevel.LOW);
            record.setStatus(RiskControlRecord.RiskStatus.APPROVED);
        }
        
        return riskControlRepository.save(record);
    }
    
    public boolean isOrderApproved(String orderNo) {
        RiskControlRecord record = riskControlRepository.findByOrderNo(orderNo)
            .orElse(null);
        return record != null && record.getStatus() == RiskControlRecord.RiskStatus.APPROVED;
    }
    
    public void manualReview(Long recordId, Integer reviewerId, String comment, boolean approved) {
        RiskControlRecord record = riskControlRepository.findById(recordId)
            .orElseThrow(() -> new BusinessException(404, "风控记录不存在"));
        
        record.setReviewerId(reviewerId);
        record.setReviewComment(comment);
        record.setReviewedAt(LocalDateTime.now());
        record.setStatus(approved ? RiskControlRecord.RiskStatus.APPROVED : RiskControlRecord.RiskStatus.REJECTED);
        
        riskControlRepository.save(record);
    }
}
