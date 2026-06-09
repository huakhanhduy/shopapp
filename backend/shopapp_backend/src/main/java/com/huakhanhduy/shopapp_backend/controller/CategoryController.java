package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.category.CategoryProductResponse;
import com.huakhanhduy.shopapp_backend.entity.Category;
import com.huakhanhduy.shopapp_backend.service.CategoryService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/categories")
@CrossOrigin("*")
public class CategoryController {

        private final CategoryService categoryService;

        public CategoryController(
                        CategoryService categoryService) {
                this.categoryService = categoryService;
        }

        @GetMapping
        public ResponseEntity<List<Category>> getAllCategories() {

                return ResponseEntity.ok(
                                categoryService.getAllCategories());
        }

        @GetMapping("/{id}")
        public ResponseEntity<Category> getCategoryById(
                        @PathVariable UUID id) {

                return ResponseEntity.ok(
                                categoryService.getCategoryById(id));
        }

        @PostMapping
        public ResponseEntity<Category> createCategory(
                        @RequestBody Category category) {

                return ResponseEntity.ok(
                                categoryService.createCategory(category));
        }

        @PutMapping("/{id}")
        public ResponseEntity<Category> updateCategory(
                        @PathVariable UUID id,
                        @RequestBody Category category) {

                return ResponseEntity.ok(
                                categoryService.updateCategory(
                                                id,
                                                category));
        }

        @DeleteMapping("/{id}")
        public ResponseEntity<String> deleteCategory(
                        @PathVariable UUID id) {

                categoryService.deleteCategory(id);

                return ResponseEntity.ok(
                                "Category deleted successfully");
        }

        @GetMapping("/{id}/products")
        public ResponseEntity<CategoryProductResponse> getProductsByCategory(
                        @PathVariable UUID id) {

                return ResponseEntity.ok(
                                categoryService
                                                .getProductsByCategory(
                                                                id));
        }
}