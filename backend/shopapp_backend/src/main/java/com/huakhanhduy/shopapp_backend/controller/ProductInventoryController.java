package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.service.ProductInventoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/inventory")
public class ProductInventoryController {

    private final ProductInventoryService productInventoryService;

    public ProductInventoryController(ProductInventoryService productInventoryService) {
        this.productInventoryService = productInventoryService;
    }

    @PostMapping("/attributes")
    public ResponseEntity<Attribute> createAttribute(@RequestBody Attribute attribute) {
        return ResponseEntity.ok(productInventoryService.createAttribute(attribute));
    }

    @GetMapping("/attributes")
    public ResponseEntity<List<Attribute>> getAllAttributes() {
        return ResponseEntity.ok(productInventoryService.getAllAttributes());
    }

    @PostMapping("/attributes/{id}/values")
    public ResponseEntity<AttributeValue> createAttributeValue(@PathVariable UUID id, @RequestBody AttributeValue value) {
        return ResponseEntity.ok(productInventoryService.createAttributeValue(id, value));
    }

    @GetMapping("/attributes/{id}/values")
    public ResponseEntity<List<AttributeValue>> getAttributeValues(@PathVariable UUID id) {
        return ResponseEntity.ok(productInventoryService.getAttributeValues(id));
    }

    @PostMapping("/products/{productId}/gallery")
    public ResponseEntity<Gallery> addImageToGallery(
            @PathVariable UUID productId,
            @RequestParam String imageUrl,
            @RequestParam String placeholder,
            @RequestParam(required = false, defaultValue = "false") Boolean isThumbnail
    ) {
        return ResponseEntity.ok(productInventoryService.addImageToGallery(productId, imageUrl, placeholder, isThumbnail));
    }

    @GetMapping("/products/{productId}/gallery")
    public ResponseEntity<List<Gallery>> getProductGallery(@PathVariable UUID productId) {
        return ResponseEntity.ok(productInventoryService.getProductGallery(productId));
    }

    @PostMapping("/products/{productId}/shipping-info")
    public ResponseEntity<ProductShippingInfo> saveShippingInfo(@PathVariable UUID productId, @RequestBody ProductShippingInfo info) {
        return ResponseEntity.ok(productInventoryService.saveShippingInfo(productId, info));
    }

    @GetMapping("/products/{productId}/shipping-info")
    public ResponseEntity<ProductShippingInfo> getShippingInfo(@PathVariable UUID productId) {
        return ResponseEntity.ok(productInventoryService.getShippingInfo(productId));
    }

    @PostMapping("/suppliers")
    public ResponseEntity<Supplier> createSupplier(@RequestBody Supplier supplier) {
        return ResponseEntity.ok(productInventoryService.createSupplier(supplier));
    }

    @GetMapping("/suppliers")
    public ResponseEntity<List<Supplier>> getAllSuppliers() {
        return ResponseEntity.ok(productInventoryService.getAllSuppliers());
    }

    @PostMapping("/products/{productId}/suppliers/{supplierId}")
    public ResponseEntity<ProductSupplier> linkProductSupplier(@PathVariable UUID productId, @PathVariable UUID supplierId) {
        return ResponseEntity.ok(productInventoryService.linkProductSupplier(productId, supplierId));
    }

    @GetMapping("/products/{productId}/suppliers")
    public ResponseEntity<List<Supplier>> getProductSuppliers(@PathVariable UUID productId) {
        return ResponseEntity.ok(productInventoryService.getProductSuppliers(productId));
    }

    @PostMapping("/variant-options")
    public ResponseEntity<VariantOption> createVariantOption(@RequestBody VariantOption option) {
        return ResponseEntity.ok(productInventoryService.createVariantOption(option));
    }

    @GetMapping("/products/{productId}/variant-options")
    public ResponseEntity<List<VariantOption>> getProductVariantOptions(@PathVariable UUID productId) {
        return ResponseEntity.ok(productInventoryService.getProductVariantOptions(productId));
    }

    @PostMapping("/variants")
    public ResponseEntity<Variant> createVariant(@RequestBody Variant variant) {
        return ResponseEntity.ok(productInventoryService.createVariant(variant));
    }

    @GetMapping("/products/{productId}/variants")
    public ResponseEntity<List<Variant>> getProductVariants(@PathVariable UUID productId) {
        return ResponseEntity.ok(productInventoryService.getProductVariants(productId));
    }
}
