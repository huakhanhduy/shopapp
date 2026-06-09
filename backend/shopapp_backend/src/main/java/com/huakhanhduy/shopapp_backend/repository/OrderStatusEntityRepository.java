package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.OrderStatusEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface OrderStatusEntityRepository extends JpaRepository<OrderStatusEntity, UUID> {
    Optional<OrderStatusEntity> findByStatusName(String statusName);
}
