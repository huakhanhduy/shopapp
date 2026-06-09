package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductTag;
import com.huakhanhduy.shopapp_backend.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductTagRepository extends JpaRepository<ProductTag, UUID> {

    List<ProductTag> findByTag(Tag tag);

    List<ProductTag> findByProduct(Product product);

    void deleteByProduct(Product product);

    void deleteByTag(Tag tag);

}