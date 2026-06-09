package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.order.OrderRequest;
import com.huakhanhduy.shopapp_backend.dto.order.OrderResponse;
import com.huakhanhduy.shopapp_backend.entity.OrderStatus;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import java.util.List;
import java.util.UUID;

public interface OrderService {
    OrderResponse placeOrder(OrderRequest request, StaffAccount user);
    List<OrderResponse> getOrders(StaffAccount user);
    List<OrderResponse> getOrdersByStatus(StaffAccount user, OrderStatus status);
    OrderResponse getOrderById(UUID orderId, StaffAccount user);
}
