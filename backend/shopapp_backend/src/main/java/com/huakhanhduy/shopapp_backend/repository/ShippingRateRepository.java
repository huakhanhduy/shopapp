package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.ShippingRate;
import com.huakhanhduy.shopapp_backend.entity.ShippingZone;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ShippingRateRepository extends JpaRepository<ShippingRate, UUID> {
    List<ShippingRate> findByShippingZone(ShippingZone shippingZone);
}
