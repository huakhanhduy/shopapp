package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.order.OrderItemRequest;
import com.huakhanhduy.shopapp_backend.dto.order.OrderRequest;
import com.huakhanhduy.shopapp_backend.dto.order.OrderResponse;
import com.huakhanhduy.shopapp_backend.dto.order.OrderDetailResponse;
import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.OrderDetailRepository;
import com.huakhanhduy.shopapp_backend.repository.OrderRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductRepository;
import com.huakhanhduy.shopapp_backend.service.OrderService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final ProductRepository productRepository;

    public OrderServiceImpl(
            OrderRepository orderRepository,
            OrderDetailRepository orderDetailRepository,
            ProductRepository productRepository
    ) {
        this.orderRepository = orderRepository;
        this.orderDetailRepository = orderDetailRepository;
        this.productRepository = productRepository;
    }

    @Override
    @Transactional
    public OrderResponse placeOrder(OrderRequest request, StaffAccount user) {
        Order order = new Order();
        order.setOrderNumber("ORD-" + System.currentTimeMillis());
        order.setOrderDate(Instant.now());
        order.setStatus(OrderStatus.PROCESSING);
        order.setShippingAddress(request.getShippingAddress());
        order.setShippingMethod(request.getShippingMethod());
        order.setPaymentMethod(request.getPaymentMethod());
        order.setSubtotal(request.getSubtotal());
        order.setDeliveryFee(request.getDeliveryFee());
        order.setDiscountAmount(request.getDiscountAmount());
        order.setTotalAmount(request.getTotalAmount());
        order.setUser(user);

        order = orderRepository.save(order);

        List<OrderDetailResponse> detailResponses = new ArrayList<>();

        for (OrderItemRequest item : request.getItems()) {
            Product product = productRepository.findById(item.getProductId())
                    .orElseThrow(() -> new RuntimeException("Sản phẩm không tồn tại: " + item.getProductId()));

            // Reduce product quantity if needed
            if (product.getQuantity() != null) {
                int newQty = Math.max(0, product.getQuantity() - item.getQuantity());
                product.setQuantity(newQty);
                productRepository.save(product);
            }

            OrderDetail detail = new OrderDetail();
            detail.setOrder(order);
            detail.setProduct(product);
            detail.setProductName(product.getProductName());
            detail.setSize(item.getSize());
            detail.setColor(item.getColor());
            detail.setPrice(item.getPrice());
            detail.setQuantity(item.getQuantity());

            detail = orderDetailRepository.save(detail);

            OrderDetailResponse itemRes = new OrderDetailResponse();
            itemRes.setId(detail.getId());
            itemRes.setProductId(product.getId());
            itemRes.setProductName(product.getProductName());
            itemRes.setProductImageUrl(product.getImageUrl());
            itemRes.setSize(detail.getSize());
            itemRes.setColor(detail.getColor());
            itemRes.setPrice(detail.getPrice());
            itemRes.setQuantity(detail.getQuantity());

            detailResponses.add(itemRes);
        }

        return mapToResponse(order, detailResponses);
    }

    @Override
    public List<OrderResponse> getOrders(StaffAccount user) {
        List<Order> orders = orderRepository.findByUserOrderByOrderDateDesc(user);
        return orders.stream().map(this::mapToResponse).toList();
    }

    @Override
    public List<OrderResponse> getOrdersByStatus(StaffAccount user, OrderStatus status) {
        List<Order> orders = orderRepository.findByUserAndStatusOrderByOrderDateDesc(user, status);
        return orders.stream().map(this::mapToResponse).toList();
    }

    @Override
    public OrderResponse getOrderById(UUID orderId, StaffAccount user) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Đơn hàng không tồn tại"));

        if (!order.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền xem đơn hàng này");
        }

        return mapToResponse(order);
    }

    private OrderResponse mapToResponse(Order order) {
        List<OrderDetail> details = orderDetailRepository.findByOrder(order);
        List<OrderDetailResponse> items = details.stream().map(d -> {
            OrderDetailResponse res = new OrderDetailResponse();
            res.setId(d.getId());
            res.setProductId(d.getProduct().getId());
            res.setProductName(d.getProductName());
            res.setProductImageUrl(d.getProduct().getImageUrl());
            res.setSize(d.getSize());
            res.setColor(d.getColor());
            res.setPrice(d.getPrice());
            res.setQuantity(d.getQuantity());
            return res;
        }).toList();

        return mapToResponse(order, items);
    }

    private OrderResponse mapToResponse(Order order, List<OrderDetailResponse> items) {
        OrderResponse res = new OrderResponse();
        res.setId(order.getId());
        res.setOrderNumber(order.getOrderNumber());
        res.setOrderDate(order.getOrderDate());
        res.setStatus(order.getStatus());
        res.setShippingAddress(order.getShippingAddress());
        res.setShippingMethod(order.getShippingMethod());
        res.setPaymentMethod(order.getPaymentMethod());
        res.setSubtotal(order.getSubtotal());
        res.setDeliveryFee(order.getDeliveryFee());
        res.setDiscountAmount(order.getDiscountAmount());
        res.setTotalAmount(order.getTotalAmount());
        res.setItems(items);
        return res;
    }
}
