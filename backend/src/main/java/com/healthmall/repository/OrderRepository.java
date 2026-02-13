package com.healthmall.repository;

import com.healthmall.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {
    
    List<Order> findByUserIdOrderByCreatedAtDesc(Integer userId);
    
    Optional<Order> findByOrderNo(String orderNo);
    
    List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(Integer userId, Order.OrderStatus status);
    
    List<Order> findByStatusAndPayExpireAtBefore(Order.OrderStatus status, LocalDateTime payExpireAt);
}
