package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.*;
import com.huakhanhduy.shopapp_backend.service.OrderStatusSalesService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class OrderStatusSalesServiceImpl implements OrderStatusSalesService {

    private final OrderStatusEntityRepository orderStatusEntityRepository;
    private final OrderRepository orderRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final SellRepository sellRepository;
    private final ProductRepository productRepository;

    public OrderStatusSalesServiceImpl(
            OrderStatusEntityRepository orderStatusEntityRepository,
            OrderRepository orderRepository,
            OrderDetailRepository orderDetailRepository,
            SellRepository sellRepository,
            ProductRepository productRepository
    ) {
        this.orderStatusEntityRepository = orderStatusEntityRepository;
        this.orderRepository = orderRepository;
        this.orderDetailRepository = orderDetailRepository;
        this.sellRepository = sellRepository;
        this.productRepository = productRepository;
    }

    @Override
    public OrderStatusEntity createOrderStatus(OrderStatusEntity status) {
        return orderStatusEntityRepository.save(status);
    }

    @Override
    public List<OrderStatusEntity> getAllOrderStatuses() {
        return orderStatusEntityRepository.findAll();
    }

    @Override
    public Order placeOrder(Order order, List<OrderDetail> items) {
        Order savedOrder = orderRepository.save(order);
        for (OrderDetail item : items) {
            item.setOrder(savedOrder);
            orderDetailRepository.save(item);
            // Record sales
            recordSale(item.getProduct().getId(), item.getPrice(), item.getQuantity());
        }
        return savedOrder;
    }

    @Override
    public Order getOrderById(UUID orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    }

    @Override
    public List<OrderDetail> getOrderItems(UUID orderId) {
        Order order = getOrderById(orderId);
        return orderDetailRepository.findByOrder(order);
    }

    @Override
    public Order updateOrderStatus(UUID orderId, UUID statusId) {
        Order order = getOrderById(orderId);
        OrderStatusEntity status = orderStatusEntityRepository.findById(statusId)
                .orElseThrow(() -> new RuntimeException("Order status not found"));
        order.setOrderStatus(status);
        return orderRepository.save(order);
    }

    @Override
    public Sell recordSale(UUID productId, Double price, Integer quantity) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        Sell sell = sellRepository.findByProduct(prod)
                .orElseGet(() -> {
                    Sell newSell = new Sell();
                    newSell.setProduct(prod);
                    newSell.setPrice(price);
                    newSell.setQuantity(0);
                    return newSell;
                });
        sell.setQuantity(sell.getQuantity() + quantity);
        sell.setPrice(price); // update last price
        return sellRepository.save(sell);
    }

    @Override
    public List<Sell> getAllSales() {
        return sellRepository.findAll();
    }
}
