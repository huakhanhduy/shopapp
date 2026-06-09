package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.ShippingAddress;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface ShippingAddressRepository extends JpaRepository<ShippingAddress, UUID> {
    List<ShippingAddress> findByUser(StaffAccount user);
    List<ShippingAddress> findByUserOrderByIsDefaultDesc(StaffAccount user);
}
