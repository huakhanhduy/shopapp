package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

import java.util.UUID;

@Entity
@Table(name = "product_tags")
public class ProductTag {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne
    private Product product;

    @ManyToOne
    private Tag tag;

    public ProductTag() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Tag getTag() {
        return tag;
    }

    public void setTag(Tag tag) {
        this.tag = tag;
    }
}