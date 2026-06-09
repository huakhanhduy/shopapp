package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.category.CategoryProductResponse;
import com.huakhanhduy.shopapp_backend.entity.Category;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductCategory;
import com.huakhanhduy.shopapp_backend.repository.CategoryRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductCategoryRepository;
import com.huakhanhduy.shopapp_backend.service.CategoryService;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class CategoryServiceImpl implements CategoryService {

        private final CategoryRepository categoryRepository;
        private final ProductCategoryRepository productCategoryRepository;

        public CategoryServiceImpl(
                        CategoryRepository categoryRepository,
                        ProductCategoryRepository productCategoryRepository) {
                this.categoryRepository = categoryRepository;

                this.productCategoryRepository = productCategoryRepository;
        }

        @Override
        public List<Category> getAllCategories() {
                return categoryRepository.findAll();
        }

        @Override
        public Category getCategoryById(
                        UUID id) {
                return categoryRepository
                                .findById(id)
                                .orElseThrow(
                                                () -> new RuntimeException(
                                                                "Category not found"));
        }

        @Override
        public Category createCategory(
                        Category category) {
                return categoryRepository.save(category);
        }

        @Override
        public Category updateCategory(
                        UUID id,
                        Category category) {

                Category existing = categoryRepository
                                .findById(id)
                                .orElseThrow(
                                                () -> new RuntimeException(
                                                                "Category not found"));

                existing.setCategoryName(
                                category.getCategoryName());

                existing.setCategoryDescription(
                                category.getCategoryDescription());

                existing.setIcon(
                                category.getIcon());

                existing.setImage(
                                category.getImage());

                existing.setActive(
                                category.getActive());

                return categoryRepository.save(existing);
        }

        @Override
        public void deleteCategory(
                        UUID id) {

                Category existing = categoryRepository
                                .findById(id)
                                .orElseThrow(
                                                () -> new RuntimeException(
                                                                "Category not found"));

                categoryRepository.delete(existing);
        }

        @Override
        public CategoryProductResponse getProductsByCategory(
                        UUID categoryId) {

                Category category = getCategoryById(categoryId);

                // Fetch all categories to identify child subcategories
                List<Category> allCategories = categoryRepository.findAll();
                List<UUID> categoryIds = new java.util.ArrayList<>();
                categoryIds.add(categoryId);

                for (Category cat : allCategories) {
                        if (cat.getParent() != null && cat.getParent().getId().equals(categoryId)) {
                                categoryIds.add(cat.getId());
                        }
                }

                List<Product> products = productCategoryRepository
                                .findByCategoryIdIn(categoryIds)
                                .stream()
                                .map(ProductCategory::getProduct)
                                .filter(product -> Boolean.TRUE.equals(product.getPublished()))
                                .distinct()
                                .toList();

                CategoryProductResponse response = new CategoryProductResponse();

                response.setCategoryId(
                                category.getId());

                response.setCategoryName(
                                category.getCategoryName());

                response.setImage(
                                category.getImage());

                response.setProducts(
                                products);

                return response;
        }
}