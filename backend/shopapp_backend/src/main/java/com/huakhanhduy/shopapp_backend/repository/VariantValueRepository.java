package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Variant;
import com.huakhanhduy.shopapp_backend.entity.VariantValue;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface VariantValueRepository extends JpaRepository<VariantValue, UUID> {
    List<VariantValue> findByVariant(Variant variant);
}
