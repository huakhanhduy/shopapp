package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.service.OrderStatusSalesService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/orders-sales")
public class OrderStatusSalesController {

    private final OrderStatusSalesService orderStatusSalesService;

    public OrderStatusSalesController(OrderStatusSalesService orderStatusSalesService) {
        this.orderStatusSalesService = orderStatusSalesService;
    }

    @PostMapping("/statuses")
    public ResponseEntity<OrderStatusEntity> createOrderStatus(@RequestBody OrderStatusEntity status) {
        return ResponseEntity.ok(orderStatusSalesService.createOrderStatus(status));
    }

    @GetMapping("/statuses")
    public ResponseEntity<List<OrderStatusEntity>> getAllOrderStatuses() {
        return ResponseEntity.ok(orderStatusSalesService.getAllOrderStatuses());
    }

    @PostMapping("/place")
    public ResponseEntity<Order> placeOrder(@RequestBody Order order, @RequestBody List<OrderDetail> items) {
        return ResponseEntity.ok(orderStatusSalesService.placeOrder(order, items));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrderById(@PathVariable UUID id) {
        return ResponseEntity.ok(orderStatusSalesService.getOrderById(id));
    }

    @GetMapping("/{id}/items")
    public ResponseEntity<List<OrderDetail>> getOrderItems(@PathVariable UUID id) {
        return ResponseEntity.ok(orderStatusSalesService.getOrderItems(id));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Order> updateOrderStatus(@PathVariable UUID id, @RequestParam UUID statusId) {
        return ResponseEntity.ok(orderStatusSalesService.updateOrderStatus(id, statusId));
    }

    @GetMapping("/sales")
    public ResponseEntity<List<Sell>> getAllSales() {
        return ResponseEntity.ok(orderStatusSalesService.getAllSales());
    }
}
