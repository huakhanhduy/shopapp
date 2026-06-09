package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "product_attribute_values")
public class ProductAttributeValue extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_id", nullable = false)
    private ProductAttribute productAttribute;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attribute_value_id", nullable = false)
    private AttributeValue attributeValue;

    public ProductAttributeValue() {}

    public ProductAttribute getProductAttribute() { return productAttribute; }
    public void setProductAttribute(ProductAttribute productAttribute) { this.productAttribute = productAttribute; }
    public AttributeValue getAttributeValue() { return attributeValue; }
    public void setAttributeValue(AttributeValue attributeValue) { this.attributeValue = attributeValue; }
}
