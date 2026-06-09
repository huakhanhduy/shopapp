package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.ProductTagRequest;
import com.huakhanhduy.shopapp_backend.entity.ProductTag;
import com.huakhanhduy.shopapp_backend.service.ProductTagService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-tags")
@CrossOrigin("*")
public class ProductTagController {

    private final ProductTagService productTagService;

    public ProductTagController(
            ProductTagService productTagService
    ) {
        this.productTagService = productTagService;
    }

    @PostMapping
    public ResponseEntity<ProductTag> create(
            @RequestBody ProductTagRequest request
    ) {

        return ResponseEntity.ok(
                productTagService.create(request)
        );
    }

    @GetMapping("/tag/{tagId}")
    public ResponseEntity<List<ProductTag>> getByTag(
            @PathVariable UUID tagId
    ) {

        return ResponseEntity.ok(
                productTagService.getByTag(tagId)
        );
    }

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<ProductTag>> getByProduct(
            @PathVariable UUID productId
    ) {

        return ResponseEntity.ok(
                productTagService.getByProduct(productId)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(
            @PathVariable UUID id
    ) {

        productTagService.delete(id);

        return ResponseEntity.ok(
                "Deleted successfully"
        );
    }
}