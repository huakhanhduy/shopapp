package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.order.OrderRequest;
import com.huakhanhduy.shopapp_backend.dto.order.OrderResponse;
import com.huakhanhduy.shopapp_backend.entity.OrderStatus;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin("*")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<OrderResponse> placeOrder(
            @RequestBody OrderRequest request,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(orderService.placeOrder(request, user));
    }

    @GetMapping
    public ResponseEntity<List<OrderResponse>> getOrders(
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(orderService.getOrders(user));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<OrderResponse>> getOrdersByStatus(
            @PathVariable OrderStatus status,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(orderService.getOrdersByStatus(user, status));
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrderById(
            @PathVariable UUID id,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(orderService.getOrderById(id, user));
    }
}
