package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.ShippingZone;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ShippingZoneRepository extends JpaRepository<ShippingZone, UUID> {
}
