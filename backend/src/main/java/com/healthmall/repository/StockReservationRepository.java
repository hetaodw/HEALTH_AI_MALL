package com.healthmall.repository;

import com.healthmall.entity.StockReservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface StockReservationRepository extends JpaRepository<StockReservation, Long> {
    
    List<StockReservation> findByOrderNo(String orderNo);
    
    List<StockReservation> findByStatusAndExpireAtBefore(
            StockReservation.ReservationStatus status, 
            LocalDateTime expireAt);
    
    @Modifying
    @Query("UPDATE StockReservation sr SET sr.status = :newStatus WHERE sr.orderNo = :orderNo AND sr.status = :oldStatus")
    int updateStatusByOrderNo(
            @Param("orderNo") String orderNo,
            @Param("oldStatus") StockReservation.ReservationStatus oldStatus,
            @Param("newStatus") StockReservation.ReservationStatus newStatus);
    
    @Modifying
    @Query("UPDATE StockReservation sr SET sr.status = :newStatus WHERE sr.productId = :productId AND sr.status = :oldStatus")
    int updateStatusByProductId(
            @Param("productId") Integer productId,
            @Param("oldStatus") StockReservation.ReservationStatus oldStatus,
            @Param("newStatus") StockReservation.ReservationStatus newStatus);
}
