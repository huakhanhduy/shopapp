package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.dto.category.CategoryProductResponse;
import com.huakhanhduy.shopapp_backend.entity.Category;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {

    List<ProductCategory> findByCategory(Category category);

    List<ProductCategory> findByProduct(Product product);

    void deleteByProduct(Product product);

    void deleteByCategory(Category category);

    List<ProductCategory> findByCategoryId(UUID categoryId);

    List<ProductCategory> findByCategoryIdIn(List<UUID> categoryIds);

}