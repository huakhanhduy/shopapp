package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.*;
import java.util.List;
import java.util.UUID;

public interface ProductInventoryService {
    // Attributes
    Attribute createAttribute(Attribute attribute);
    List<Attribute> getAllAttributes();
    AttributeValue createAttributeValue(UUID attributeId, AttributeValue value);
    List<AttributeValue> getAttributeValues(UUID attributeId);

    // Gallery
    Gallery addImageToGallery(UUID productId, String imageUrl, String placeholder, Boolean isThumbnail);
    List<Gallery> getProductGallery(UUID productId);

    // Shipping Info
    ProductShippingInfo saveShippingInfo(UUID productId, ProductShippingInfo info);
    ProductShippingInfo getShippingInfo(UUID productId);

    // Suppliers
    Supplier createSupplier(Supplier supplier);
    List<Supplier> getAllSuppliers();
    ProductSupplier linkProductSupplier(UUID productId, UUID supplierId);
    List<Supplier> getProductSuppliers(UUID productId);

    // Variants
    VariantOption createVariantOption(VariantOption option);
    List<VariantOption> getProductVariantOptions(UUID productId);
    Variant createVariant(Variant variant);
    List<Variant> getProductVariants(UUID productId);
}
