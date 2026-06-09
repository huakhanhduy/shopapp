package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.category.CategoryProductResponse;
import com.huakhanhduy.shopapp_backend.entity.Category;

import java.util.List;
import java.util.UUID;

public interface CategoryService {

    List<Category> getAllCategories();

    Category getCategoryById(UUID id);

    Category createCategory(Category category);

    Category updateCategory(
            UUID id,
            Category category);

    void deleteCategory(UUID id);

    CategoryProductResponse getProductsByCategory(
            UUID categoryId);
}