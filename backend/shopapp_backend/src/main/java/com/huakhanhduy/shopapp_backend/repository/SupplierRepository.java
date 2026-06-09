package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface SupplierRepository extends JpaRepository<Supplier, UUID> {
}
