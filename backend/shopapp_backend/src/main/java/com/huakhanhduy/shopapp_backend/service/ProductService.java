package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.Product;

import java.util.List;
import java.util.UUID;

public interface ProductService {

    List<Product> getAllProducts();

    Product getProductById(UUID id);

    Product createProduct(Product product);

    Product updateProduct(
            UUID id,
            Product product
    );

    void deleteProduct(UUID id);

    List<Product> getRelatedProducts(UUID productId);

    List<Product> getProductsFiltered(String keyword, Double minPrice, Double maxPrice, String size, String color, String sort, UUID categoryId);

    List<Product> getVisualSearchResults();
}