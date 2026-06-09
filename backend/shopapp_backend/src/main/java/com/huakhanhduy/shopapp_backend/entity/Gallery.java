package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "gallery")
public class Gallery extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String image;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String placeholder;

    private Boolean isThumbnail = false;

    public Gallery() {}

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getPlaceholder() { return placeholder; }
    public void setPlaceholder(String placeholder) { this.placeholder = placeholder; }
    public Boolean getIsThumbnail() { return isThumbnail; }
    public void setIsThumbnail(Boolean isThumbnail) { this.isThumbnail = isThumbnail; }
}
