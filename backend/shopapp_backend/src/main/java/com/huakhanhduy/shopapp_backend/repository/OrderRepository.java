package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Order;
import com.huakhanhduy.shopapp_backend.entity.OrderStatus;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID> {
    List<Order> findByUserOrderByOrderDateDesc(StaffAccount user);
    List<Order> findByUserAndStatusOrderByOrderDateDesc(StaffAccount user, OrderStatus status);
}
