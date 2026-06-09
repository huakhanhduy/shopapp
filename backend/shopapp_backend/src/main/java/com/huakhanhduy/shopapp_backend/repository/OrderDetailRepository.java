package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.OrderDetail;
import com.huakhanhduy.shopapp_backend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderDetailRepository extends JpaRepository<OrderDetail, UUID> {
    List<OrderDetail> findByOrder(Order order);
}
