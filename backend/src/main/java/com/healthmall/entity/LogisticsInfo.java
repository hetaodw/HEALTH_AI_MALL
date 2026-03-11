package com.healthmall.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "logistics_info")
public class LogisticsInfo {
    
    public enum LogisticsCompany {
        TEST,
        SF,
        STO,
        YTO,
        ZTO,
        EMS
    }
    
    public enum LogisticsStatus {
        CREATED,
        PICKED,
        IN_TRANSIT,
        DELIVERED,
        EXCEPTION
    }
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_no", nullable = false, unique = true, length = 32)
    private String orderNo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "logistics_company", nullable = false, length = 20)
    private LogisticsCompany logisticsCompany;
    
    @Column(name = "tracking_no", nullable = false, length = 50)
    private String trackingNo;
    
    @Column(name = "waybill_url", length = 255)
    private String waybillUrl;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private LogisticsStatus status = LogisticsStatus.CREATED;
    
    @Column(name = "estimated_delivery")
    private LocalDateTime estimatedDelivery;
    
    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;
    
    @Column(name = "trace_info", columnDefinition = "TEXT")
    private String traceInfo;
    
    @Column(name = "cainiao_subscribed")
    private Boolean cainiaoSubscribed = false;
    
    @Column(name = "cainiao_last_update")
    private LocalDateTime cainiaoLastUpdate;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public LogisticsCompany getLogisticsCompany() {
        return logisticsCompany;
    }

    public void setLogisticsCompany(LogisticsCompany logisticsCompany) {
        this.logisticsCompany = logisticsCompany;
    }

    public String getTrackingNo() {
        return trackingNo;
    }

    public void setTrackingNo(String trackingNo) {
        this.trackingNo = trackingNo;
    }

    public String getWaybillUrl() {
        return waybillUrl;
    }

    public void setWaybillUrl(String waybillUrl) {
        this.waybillUrl = waybillUrl;
    }

    public LogisticsStatus getStatus() {
        return status;
    }

    public void setStatus(LogisticsStatus status) {
        this.status = status;
    }

    public LocalDateTime getEstimatedDelivery() {
        return estimatedDelivery;
    }

    public void setEstimatedDelivery(LocalDateTime estimatedDelivery) {
        this.estimatedDelivery = estimatedDelivery;
    }

    public LocalDateTime getDeliveredAt() {
        return deliveredAt;
    }

    public void setDeliveredAt(LocalDateTime deliveredAt) {
        this.deliveredAt = deliveredAt;
    }

    public String getTraceInfo() {
        return traceInfo;
    }

    public void setTraceInfo(String traceInfo) {
        this.traceInfo = traceInfo;
    }

    public Boolean getCainiaoSubscribed() {
        return cainiaoSubscribed;
    }

    public void setCainiaoSubscribed(Boolean cainiaoSubscribed) {
        this.cainiaoSubscribed = cainiaoSubscribed;
    }

    public LocalDateTime getCainiaoLastUpdate() {
        return cainiaoLastUpdate;
    }

    public void setCainiaoLastUpdate(LocalDateTime cainiaoLastUpdate) {
        this.cainiaoLastUpdate = cainiaoLastUpdate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
