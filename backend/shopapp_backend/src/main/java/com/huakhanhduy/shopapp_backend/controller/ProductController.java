package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductVariant;
import com.huakhanhduy.shopapp_backend.repository.ProductVariantRepository;
import com.huakhanhduy.shopapp_backend.service.ProductService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@CrossOrigin("*")
public class ProductController {

    private final ProductService productService;
    private final ProductVariantRepository productVariantRepository;

    public ProductController(
            ProductService productService,
            ProductVariantRepository productVariantRepository
    ) {
        this.productService = productService;
        this.productVariantRepository = productVariantRepository;
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) String size,
            @RequestParam(required = false) String color,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) UUID categoryId
    ) {
        return ResponseEntity.ok(
                productService.getProductsFiltered(keyword, minPrice, maxPrice, size, color, sort, categoryId)
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product>
    getProductById(
            @PathVariable UUID id
    ) {

        return ResponseEntity.ok(
                productService.getProductById(id)
        );
    }

    @PostMapping
    public ResponseEntity<Product>
    createProduct(
            @RequestBody Product product
    ) {

        return ResponseEntity.ok(
                productService.createProduct(product)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product>
    updateProduct(
            @PathVariable UUID id,
            @RequestBody Product product
    ) {

        return ResponseEntity.ok(
                productService.updateProduct(
                        id,
                        product
                )
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String>
    deleteProduct(
            @PathVariable UUID id
    ) {

        productService.deleteProduct(id);

        return ResponseEntity.ok(
                "Product deleted successfully"
        );
    }

    @GetMapping("/{id}/related")
    public ResponseEntity<List<Product>> getRelatedProducts(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                productService.getRelatedProducts(id)
        );
    }

    @PostMapping("/visual-search")
    public ResponseEntity<List<Product>> visualSearch() {
        return ResponseEntity.ok(productService.getVisualSearchResults());
    }

    @GetMapping("/{id}/variants")
    public ResponseEntity<List<ProductVariant>> getProductVariants(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(productVariantRepository.findByProductId(id));
    }
}