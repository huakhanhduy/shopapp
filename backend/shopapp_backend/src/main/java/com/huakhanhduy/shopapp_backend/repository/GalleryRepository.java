package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Gallery;
import com.huakhanhduy.shopapp_backend.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface GalleryRepository extends JpaRepository<Gallery, UUID> {
    List<Gallery> findByProduct(Product product);
}
