package com.healthmall.service;

import com.healthmall.dto.CreateOrderRequest;
import com.healthmall.dto.OrderResponse;
import com.healthmall.entity.*;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.*;
import com.healthmall.util.SnowflakeIdGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private static final int PAY_EXPIRE_MINUTES = 15;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductSnapshotRepository snapshotRepository;

    @Autowired
    private AddressRepository addressRepository;

    @Autowired
    private StockReservationRepository reservationRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SnowflakeIdGenerator idGenerator;

    @Autowired
    private StockReservationService stockReservationService;

    @Transactional
    public OrderResponse createOrder(Integer userId, CreateOrderRequest request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(400, "订单商品不能为空");
        }

        Address address = validateAndGetAddress(userId, request.getAddressId());

        List<OrderItemData> itemDataList = validateAndPrepareItems(request.getItems());

        String orderNo = idGenerator.generateOrderNo();

        reserveStockForItems(itemDataList, orderNo);

        Order order = createOrderEntity(userId, address, request, itemDataList, orderNo);

        List<ProductSnapshot> snapshots = createAndSaveSnapshots(itemDataList);
        
        List<OrderItem> orderItems = createOrderItems(order, itemDataList, snapshots);
        order.setItems(orderItems);

        createStockReservationRecords(orderNo, itemDataList);

        return convertToResponse(order, orderItems, snapshots);
    }

    private Address validateAndGetAddress(Integer userId, Integer addressId) {
        if (addressId == null) {
            throw new BusinessException(400, "请选择收货地址");
        }
        
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new BusinessException(400, "收货地址不存在"));
        
        if (!address.getUserId().equals(userId)) {
            throw new BusinessException(400, "收货地址不属于当前用户");
        }
        
        return address;
    }

    private List<OrderItemData> validateAndPrepareItems(List<CreateOrderRequest.OrderItemRequest> items) {
        List<OrderItemData> itemDataList = new ArrayList<>();
        
        for (CreateOrderRequest.OrderItemRequest item : items) {
            Product product = productRepository.findById(item.getProductId())
                    .orElseThrow(() -> new BusinessException(400, "商品不存在: " + item.getProductId()));

            if (product.getStatus() != Product.ProductStatus.ON_SALE) {
                throw new BusinessException(400, "商品已下架或缺货: " + product.getTitle());
            }

            if (product.getStock() < item.getQuantity()) {
                throw new BusinessException(400, "库存不足: " + product.getTitle());
            }

            String merchantName = getMerchantName(product.getMerchantId());

            itemDataList.add(new OrderItemData(product, item.getQuantity(), merchantName));
        }
        
        return itemDataList;
    }

    private String getMerchantName(Integer merchantId) {
        if (merchantId == null) {
            return "官方店铺";
        }
        return userRepository.findById(merchantId)
                .map(User::getUsername)
                .orElse("官方店铺");
    }

    private void reserveStockForItems(List<OrderItemData> itemDataList, String orderNo) {
        for (OrderItemData itemData : itemDataList) {
            try {
                stockReservationService.syncStockFromDb(
                        itemData.product.getId(), 
                        itemData.product.getStock()
                );
                stockReservationService.reserveStock(
                        itemData.product.getId(), 
                        orderNo, 
                        itemData.quantity
                );
            } catch (Exception e) {
                releaseAllStock(itemDataList, orderNo);
                throw new BusinessException(400, "库存预占失败: " + e.getMessage());
            }
        }
    }

    private void releaseAllStock(List<OrderItemData> itemDataList, String orderNo) {
        for (OrderItemData itemData : itemDataList) {
            try {
                stockReservationService.releaseReservation(
                        itemData.product.getId(), 
                        orderNo
                );
            } catch (Exception ignored) {
            }
        }
    }

    private Order createOrderEntity(Integer userId, Address address, CreateOrderRequest request, 
                                    List<OrderItemData> itemDataList, String orderNo) {
        Order order = new Order();
        order.setOrderNo(orderNo);
        order.setUserId(userId);
        order.setAddressId(address.getId());
        order.setReceiverName(address.getReceiverName());
        order.setReceiverPhone(address.getReceiverPhone());
        order.setReceiverAddress(address.getFullAddress());
        order.setRemark(request.getRemark());
        order.setStatus(Order.OrderStatus.PENDING_PAYMENT);
        order.setPayExpireAt(LocalDateTime.now().plusMinutes(PAY_EXPIRE_MINUTES));
        order.setItemCount(itemDataList.size());

        BigDecimal totalAmount = itemDataList.stream()
                .map(item -> item.product.getPrice().multiply(BigDecimal.valueOf(item.quantity)))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        order.setTotalAmount(totalAmount);

        return orderRepository.save(order);
    }

    private List<ProductSnapshot> createAndSaveSnapshots(List<OrderItemData> itemDataList) {
        List<ProductSnapshot> snapshots = itemDataList.stream()
                .map(item -> ProductSnapshot.fromProduct(item.product, item.merchantName))
                .collect(Collectors.toList());
        return snapshotRepository.saveAll(snapshots);
    }

    private List<OrderItem> createOrderItems(Order order, List<OrderItemData> itemDataList, 
                                              List<ProductSnapshot> snapshots) {
        List<OrderItem> orderItems = new ArrayList<>();
        
        for (int i = 0; i < itemDataList.size(); i++) {
            OrderItemData itemData = itemDataList.get(i);
            ProductSnapshot snapshot = snapshots.get(i);
            
            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(order.getId());
            orderItem.setProductId(itemData.product.getId());
            orderItem.setSnapshotId(snapshot.getId());
            orderItem.setQuantity(itemData.quantity);
            orderItem.setUnitPrice(itemData.product.getPrice());
            orderItem.setTotalPrice(itemData.product.getPrice()
                    .multiply(BigDecimal.valueOf(itemData.quantity)));
            
            orderItems.add(orderItemRepository.save(orderItem));
        }
        
        return orderItems;
    }

    private void createStockReservationRecords(String orderNo, List<OrderItemData> itemDataList) {
        LocalDateTime expireAt = LocalDateTime.now().plusMinutes(PAY_EXPIRE_MINUTES);
        
        for (OrderItemData itemData : itemDataList) {
            StockReservation reservation = new StockReservation();
            reservation.setOrderNo(orderNo);
            reservation.setProductId(itemData.product.getId());
            reservation.setQuantity(itemData.quantity);
            reservation.setStatus(StockReservation.ReservationStatus.RESERVED);
            reservation.setExpireAt(expireAt);
            reservationRepository.save(reservation);
        }
    }

    @Transactional
    public OrderResponse payOrder(Integer userId, String orderNo, Payment.PaymentMethod payMethod) {
        Order order = orderRepository.findByOrderNo(orderNo)
                .orElseThrow(() -> new BusinessException(404, "订单不存在"));

        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作此订单");
        }

        if (order.getStatus() != Order.OrderStatus.PENDING_PAYMENT) {
            throw new BusinessException(400, "订单状态不允许支付");
        }

        if (LocalDateTime.now().isAfter(order.getPayExpireAt())) {
            cancelOrder(userId, order.getId(), "支付超时");
            throw new BusinessException(400, "订单已超时，请重新下单");
        }

        Payment payment = new Payment();
        payment.setOrderNo(orderNo);
        payment.setAmount(order.getTotalAmount());
        payment.setPayMethod(payMethod);
        payment.setStatus(Payment.PaymentStatus.SUCCESS);
        payment.setPayNo("PAY" + idGenerator.generateOrderNo());
        payment.setPaidAt(LocalDateTime.now());
        paymentRepository.save(payment);

        order.setStatus(Order.OrderStatus.PAID);
        order.setPaidAt(LocalDateTime.now());
        orderRepository.save(order);

        confirmStockReservation(orderNo);

        deductStockFromDb(orderNo);

        return getOrderDetail(userId, order.getId());
    }

    private void confirmStockReservation(String orderNo) {
        List<StockReservation> reservations = reservationRepository.findByOrderNo(orderNo);
        for (StockReservation reservation : reservations) {
            reservation.setStatus(StockReservation.ReservationStatus.CONFIRMED);
            reservationRepository.save(reservation);
            
            stockReservationService.confirmReservation(reservation.getProductId(), orderNo);
        }
    }

    private void deductStockFromDb(String orderNo) {
        List<StockReservation> reservations = reservationRepository.findByOrderNo(orderNo);
        for (StockReservation reservation : reservations) {
            Product product = productRepository.findById(reservation.getProductId()).orElse(null);
            if (product != null) {
                product.setStock(product.getStock() - reservation.getQuantity());
                product.setSales(product.getSales() + reservation.getQuantity());
                productRepository.save(product);
            }
        }
    }

    @Transactional
    public boolean cancelOrder(Integer userId, Integer orderId, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new BusinessException(404, "订单不存在"));

        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作此订单");
        }

        if (order.getStatus() != Order.OrderStatus.PENDING_PAYMENT) {
            throw new BusinessException(400, "订单状态不允许取消");
        }

        releaseStockReservation(order.getOrderNo());

        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());
        order.setCancelReason(reason);
        orderRepository.save(order);

        return true;
    }

    private void releaseStockReservation(String orderNo) {
        List<StockReservation> reservations = reservationRepository.findByOrderNo(orderNo);
        for (StockReservation reservation : reservations) {
            if (reservation.getStatus() == StockReservation.ReservationStatus.RESERVED) {
                reservation.setStatus(StockReservation.ReservationStatus.RELEASED);
                reservationRepository.save(reservation);
                
                stockReservationService.releaseReservation(reservation.getProductId(), orderNo);
            }
        }
    }

    public OrderResponse getOrderDetail(Integer userId, Integer orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new BusinessException(404, "订单不存在"));

        if (!order.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权查看此订单");
        }

        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
        List<Long> snapshotIds = items.stream()
                .map(OrderItem::getSnapshotId)
                .collect(Collectors.toList());
        List<ProductSnapshot> snapshots = snapshotRepository.findAllById(snapshotIds);

        return convertToResponse(order, items, snapshots);
    }

    public List<OrderResponse> getUserOrders(Integer userId, Order.OrderStatus status) {
        List<Order> orders;
        if (status != null) {
            orders = orderRepository.findByUserIdAndStatusOrderByCreatedAtDesc(userId, status);
        } else {
            orders = orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
        }

        return orders.stream()
                .map(order -> {
                    List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
                    List<ProductSnapshot> snapshots = snapshotRepository.findAllById(
                            items.stream().map(OrderItem::getSnapshotId).collect(Collectors.toList())
                    );
                    return convertToResponse(order, items, snapshots);
                })
                .collect(Collectors.toList());
    }

    private OrderResponse convertToResponse(Order order, List<OrderItem> items, List<ProductSnapshot> snapshots) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setOrderNo(order.getOrderNo());
        response.setUserId(order.getUserId());
        response.setTotalAmount(order.getTotalAmount());
        response.setItemCount(order.getItemCount());
        response.setStatus(order.getStatus());
        response.setPayExpireAt(order.getPayExpireAt());
        response.setReceiverName(order.getReceiverName());
        response.setReceiverPhone(order.getReceiverPhone());
        response.setReceiverAddress(order.getReceiverAddress());
        response.setRemark(order.getRemark());
        response.setPaidAt(order.getPaidAt());
        response.setShippedAt(order.getShippedAt());
        response.setCompletedAt(order.getCompletedAt());
        response.setCancelledAt(order.getCancelledAt());
        response.setCancelReason(order.getCancelReason());
        response.setCreatedAt(order.getCreatedAt());

        List<OrderResponse.OrderItemResponse> itemResponses = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            OrderItem item = items.get(i);
            ProductSnapshot snapshot = snapshots.stream()
                    .filter(s -> s.getId().equals(item.getSnapshotId()))
                    .findFirst()
                    .orElse(null);

            OrderResponse.OrderItemResponse itemResponse = new OrderResponse.OrderItemResponse();
            itemResponse.setId(item.getId());
            itemResponse.setProductId(item.getProductId());
            itemResponse.setQuantity(item.getQuantity());
            itemResponse.setUnitPrice(item.getUnitPrice());
            itemResponse.setTotalPrice(item.getTotalPrice());

            if (snapshot != null) {
                itemResponse.setProductTitle(snapshot.getTitle());
                itemResponse.setProductCoverUrl(snapshot.getCoverUrl());
                itemResponse.setCategory(snapshot.getCategory());
                itemResponse.setMerchantName(snapshot.getMerchantName());
            }

            itemResponses.add(itemResponse);
        }
        response.setItems(itemResponses);

        return response;
    }

    private static class OrderItemData {
        final Product product;
        final Integer quantity;
        final String merchantName;

        OrderItemData(Product product, Integer quantity, String merchantName) {
            this.product = product;
            this.quantity = quantity;
            this.merchantName = merchantName;
        }
    }
}
