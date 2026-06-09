package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductShippingInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface ProductShippingInfoRepository extends JpaRepository<ProductShippingInfo, UUID> {
    Optional<ProductShippingInfo> findByProduct(Product product);
}
