package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductSupplier;
import com.huakhanhduy.shopapp_backend.entity.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProductSupplierRepository extends JpaRepository<ProductSupplier, UUID> {
    List<ProductSupplier> findByProduct(Product product);
    List<ProductSupplier> findBySupplier(Supplier supplier);
}
