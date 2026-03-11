package com.healthmall.repository;

import com.healthmall.entity.RiskControlRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RiskControlRepository extends JpaRepository<RiskControlRecord, Long> {
    
    Optional<RiskControlRecord> findByOrderNo(String orderNo);
    
    List<RiskControlRecord> findByUserIdOrderByCreatedAtDesc(Integer userId);
    
    List<RiskControlRecord> findByStatusAndCreatedAtBefore(
        RiskControlRecord.RiskStatus status, 
        LocalDateTime createdAt
    );
}
