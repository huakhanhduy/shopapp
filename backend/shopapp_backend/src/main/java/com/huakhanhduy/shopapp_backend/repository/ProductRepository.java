package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {

    List<Product> findByPublishedTrue();

    List<Product> findByProductNameContainingIgnoreCase(String keyword);

    @Query("SELECT DISTINCT p FROM Product p WHERE p.id <> :productId AND p.published = true AND (" +
           "EXISTS (SELECT pc1.id FROM ProductCategory pc1 WHERE pc1.product = p AND pc1.category IN " +
           "  (SELECT pc2.category FROM ProductCategory pc2 WHERE pc2.product.id = :productId)) OR " +
           "EXISTS (SELECT pt1.id FROM ProductTag pt1 WHERE pt1.product = p AND pt1.tag IN " +
           "  (SELECT pt2.tag FROM ProductTag pt2 WHERE pt2.product.id = :productId))" +
           ")")
    List<Product> findRelatedProducts(@Param("productId") UUID productId);
}