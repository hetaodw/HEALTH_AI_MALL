package com.healthmall.repository;

import com.healthmall.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    
    Optional<Payment> findByOrderNo(String orderNo);
    
    Optional<Payment> findByPayNo(String payNo);
}
