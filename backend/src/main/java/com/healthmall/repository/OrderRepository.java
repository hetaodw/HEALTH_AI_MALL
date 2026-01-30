package com.healthmall.repository;

import com.healthmall.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {
    
    /**
     * 根据用户ID查询订单列表，按创建时间倒序
     */
    List<Order> findByUserIdOrderByCreatedAtDesc(Integer userId);
    
    /**
     * 根据订单号查询订单
     */
    Optional<Order> findByOrderNo(String orderNo);
    
    /**
     * 根据用户ID和订单状态查询订单
     */
    List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(Integer userId, Order.OrderStatus status);
}
