package com.huakhanhduy.shopapp_backend.dto.category;

import com.huakhanhduy.shopapp_backend.entity.Product;

import java.util.List;
import java.util.UUID;

public class CategoryProductResponse {

    private UUID categoryId;

    private String categoryName;

    private String image;

    private List<Product> products;

    public UUID getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(UUID categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public List<Product> getProducts() {
        return products;
    }

    public void setProducts(List<Product> products) {
        this.products = products;
    }
}