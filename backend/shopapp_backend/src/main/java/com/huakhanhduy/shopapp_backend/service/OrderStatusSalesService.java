package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.*;
import java.util.List;
import java.util.UUID;

public interface OrderStatusSalesService {
    // Order Status
    OrderStatusEntity createOrderStatus(OrderStatusEntity status);
    List<OrderStatusEntity> getAllOrderStatuses();

    // Orders & Items
    Order placeOrder(Order order, List<OrderDetail> items);
    Order getOrderById(UUID orderId);
    List<OrderDetail> getOrderItems(UUID orderId);
    Order updateOrderStatus(UUID orderId, UUID statusId);

    // Sales
    Sell recordSale(UUID productId, Double price, Integer quantity);
    List<Sell> getAllSales();
}
