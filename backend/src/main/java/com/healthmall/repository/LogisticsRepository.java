package com.healthmall.repository;

import com.healthmall.entity.LogisticsInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LogisticsRepository extends JpaRepository<LogisticsInfo, Long> {
    
    Optional<LogisticsInfo> findByOrderNo(String orderNo);
    
    Optional<LogisticsInfo> findByTrackingNo(String trackingNo);
    
    List<LogisticsInfo> findByStatus(LogisticsInfo.LogisticsStatus status);
}
