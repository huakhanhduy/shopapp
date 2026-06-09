package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "variant_values")
public class VariantValue extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id", nullable = false)
    private Variant variant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_value_id", nullable = false)
    private ProductAttributeValue productAttributeValue;

    public VariantValue() {}

    public Variant getVariant() { return variant; }
    public void setVariant(Variant variant) { this.variant = variant; }
    public ProductAttributeValue getProductAttributeValue() { return productAttributeValue; }
    public void setProductAttributeValue(ProductAttributeValue productAttributeValue) { this.productAttributeValue = productAttributeValue; }
}
