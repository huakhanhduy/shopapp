package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Notification;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByAccountOrderByCreatedAtDesc(StaffAccount account);
}
