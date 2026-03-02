package com.healthmall.task;

import com.healthmall.entity.Order;
import com.healthmall.entity.Product;
import com.healthmall.entity.StockReservation;
import com.healthmall.repository.OrderRepository;
import com.healthmall.repository.ProductRepository;
import com.healthmall.repository.StockReservationRepository;
import com.healthmall.service.OrderService;
import com.healthmall.service.StockReservationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单定时任务
 * 处理超时订单和预占库存释放
 */
@Component
public class OrderScheduledTask {

    private static final Logger logger = LoggerFactory.getLogger(OrderScheduledTask.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private StockReservationRepository reservationRepository;

    @Autowired
    private StockReservationService stockReservationService;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private OrderService orderService;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void cancelExpiredOrders() {
        logger.info("开始检查超时订单...");
        
        List<Order> expiredOrders = orderRepository.findByStatusAndPayExpireAtBefore(
                Order.OrderStatus.PENDING_PAYMENT,
                LocalDateTime.now()
        );

        for (Order order : expiredOrders) {
            try {
                cancelExpiredOrder(order);
                logger.info("订单 {} 已超时取消", order.getOrderNo());
            } catch (Exception e) {
                logger.error("取消超时订单 {} 失败: {}", order.getOrderNo(), e.getMessage());
            }
        }
        
        logger.info("超时订单检查完成，共处理 {} 个订单", expiredOrders.size());
    }

    private void cancelExpiredOrder(Order order) {
        List<StockReservation> reservations = reservationRepository.findByOrderNo(order.getOrderNo());
        
        for (StockReservation reservation : reservations) {
            if (reservation.getStatus() == StockReservation.ReservationStatus.RESERVED) {
                reservation.setStatus(StockReservation.ReservationStatus.RELEASED);
                reservationRepository.save(reservation);
                
                stockReservationService.releaseReservation(reservation.getProductId(), order.getOrderNo());
                
                Product product = productRepository.findById(reservation.getProductId()).orElse(null);
                if (product != null) {
                    product.setStock(product.getStock() + reservation.getQuantity());
                    productRepository.save(product);
                }
            }
        }
        
        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());
        order.setCancelReason("支付超时自动取消");
        orderRepository.save(order);
    }

    @Scheduled(fixedRate = 300000)
    @Transactional
    public void cleanupExpiredReservations() {
        logger.info("开始清理过期预占记录...");
        
        List<StockReservation> expiredReservations = reservationRepository
                .findByStatusAndExpireAtBefore(
                        StockReservation.ReservationStatus.RESERVED,
                        LocalDateTime.now()
                );

        for (StockReservation reservation : expiredReservations) {
            try {
                reservation.setStatus(StockReservation.ReservationStatus.RELEASED);
                reservationRepository.save(reservation);
                
                stockReservationService.releaseReservation(
                        reservation.getProductId(), 
                        reservation.getOrderNo()
                );
                
                Product product = productRepository.findById(reservation.getProductId()).orElse(null);
                if (product != null) {
                    product.setStock(product.getStock() + reservation.getQuantity());
                    productRepository.save(product);
                }
                
                logger.info("预占记录 {} 已释放", reservation.getId());
            } catch (Exception e) {
                logger.error("释放预占记录 {} 失败: {}", reservation.getId(), e.getMessage());
            }
        }
        
        logger.info("过期预占记录清理完成，共处理 {} 条记录", expiredReservations.size());
    }

    @Scheduled(fixedRate = 60000)
    public void autoConfirmPendingOrders() {
        logger.info("开始自动确认订单...");
        try {
            orderService.autoConfirmOrders();
            logger.info("自动确认订单任务完成");
        } catch (Exception e) {
            logger.error("自动确认订单任务失败: {}", e.getMessage());
        }
    }

    @Scheduled(fixedRate = 60000)
    public void autoRejectExpiredOrders() {
        logger.info("开始自动拒绝超时订单...");
        try {
            orderService.autoRejectExpiredOrders();
            logger.info("自动拒绝超时订单任务完成");
        } catch (Exception e) {
            logger.error("自动拒绝超时订单任务失败: {}", e.getMessage());
        }
    }
}
