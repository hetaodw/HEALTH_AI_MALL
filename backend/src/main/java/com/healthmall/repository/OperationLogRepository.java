package com.healthmall.repository;

import com.healthmall.entity.OperationLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OperationLogRepository extends JpaRepository<OperationLog, Long> {
    
    List<OperationLog> findByUserIdOrderByCreatedAtDesc(Integer userId);
    
    List<OperationLog> findByModuleAndCreatedAtAfterOrderByCreatedAtDesc(
        String module, 
        LocalDateTime createdAt
    );
}
