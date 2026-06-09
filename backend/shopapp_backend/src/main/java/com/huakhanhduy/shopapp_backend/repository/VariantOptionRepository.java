package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.VariantOption;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface VariantOptionRepository extends JpaRepository<VariantOption, UUID> {
    List<VariantOption> findByProduct(Product product);
}
