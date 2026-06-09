package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "variants")
public class Variant extends BaseEntity {

    @Column(name = "variant_option", nullable = false, columnDefinition = "TEXT")
    private String variantOption;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_option_id", nullable = false)
    private VariantOption variantOptionRef;

    public Variant() {}

    public String getVariantOption() { return variantOption; }
    public void setVariantOption(String variantOption) { this.variantOption = variantOption; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public VariantOption getVariantOptionRef() { return variantOptionRef; }
    public void setVariantOptionRef(VariantOption variantOptionRef) { this.variantOptionRef = variantOptionRef; }
}
