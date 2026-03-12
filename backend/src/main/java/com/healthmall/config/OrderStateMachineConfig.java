package com.healthmall.config;

import com.healthmall.entity.Order;
import com.healthmall.exception.BusinessException;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;
import java.util.Set;

@Component
public class OrderStateMachineConfig {
    
    private final Map<Order.OrderStatus, Set<Order.OrderStatus>> allowedTransitions;
    
    public OrderStateMachineConfig() {
        allowedTransitions = new EnumMap<>(Order.OrderStatus.class);
        
        allowedTransitions.put(Order.OrderStatus.PENDING_CONFIRMATION, Set.of(
            Order.OrderStatus.CONFIRMED,
            Order.OrderStatus.REJECTED,
            Order.OrderStatus.CANCELLED
        ));
        
        allowedTransitions.put(Order.OrderStatus.CONFIRMED, Set.of(
            Order.OrderStatus.PENDING_PAYMENT,
            Order.OrderStatus.PAID,
            Order.OrderStatus.CANCELLED
        ));
        
        allowedTransitions.put(Order.OrderStatus.REJECTED, Set.of());
        
        allowedTransitions.put(Order.OrderStatus.PENDING_PAYMENT, Set.of(
            Order.OrderStatus.PAID,
            Order.OrderStatus.CANCELLED
        ));
        
        allowedTransitions.put(Order.OrderStatus.PAID, Set.of(
            Order.OrderStatus.SHIPPED,
            Order.OrderStatus.REFUNDED
        ));
        
        allowedTransitions.put(Order.OrderStatus.SHIPPED, Set.of(
            Order.OrderStatus.DELIVERED,
            Order.OrderStatus.REFUNDED
        ));
        
        allowedTransitions.put(Order.OrderStatus.DELIVERED, Set.of(
            Order.OrderStatus.COMPLETED,
            Order.OrderStatus.REFUNDED
        ));
        
        allowedTransitions.put(Order.OrderStatus.COMPLETED, Set.of(
            Order.OrderStatus.REFUNDED
        ));
        
        allowedTransitions.put(Order.OrderStatus.CANCELLED, Set.of());
        
        allowedTransitions.put(Order.OrderStatus.REFUNDED, Set.of());
    }
    
    public boolean canTransition(Order.OrderStatus from, Order.OrderStatus to) {
        if (from == null || to == null) {
            return false;
        }
        
        Set<Order.OrderStatus> allowedStatuses = allowedTransitions.get(from);
        return allowedStatuses != null && allowedStatuses.contains(to);
    }
    
    public void validateTransition(Order.OrderStatus from, Order.OrderStatus to) {
        if (!canTransition(from, to)) {
            throw new BusinessException(400, 
                String.format("不允许从状态 %s 转换到状态 %s", from, to));
        }
    }
    
    public Set<Order.OrderStatus> getNextAllowedStatuses(Order.OrderStatus currentStatus) {
        return allowedTransitions.getOrDefault(currentStatus, Set.of());
    }
}
