package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "variant_options")
public class VariantOption extends BaseEntity {

    @Column(nullable = false, columnDefinition = "TEXT")
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "image_id")
    private Gallery image;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(nullable = false)
    private Double salePrice = 0.0;

    private Double comparePrice = 0.0;

    private Double buyingPrice;

    @Column(nullable = false)
    private Integer quantity = 0;

    @Column(length = 255)
    private String sku;

    private Boolean active = true;

    public VariantOption() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Gallery getImage() { return image; }
    public void setImage(Gallery image) { this.image = image; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public Double getSalePrice() { return salePrice; }
    public void setSalePrice(Double salePrice) { this.salePrice = salePrice; }
    public Double getComparePrice() { return comparePrice; }
    public void setComparePrice(Double comparePrice) { this.comparePrice = comparePrice; }
    public Double getBuyingPrice() { return buyingPrice; }
    public void setBuyingPrice(Double buyingPrice) { this.buyingPrice = buyingPrice; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
