package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;

@Entity
@Table(name = "products")
public class Product extends BaseEntity {

    private String productName;

    @Column(unique = true)
    private String slug;

    private String sku;

    private String imageUrl;

    @Column(name = "compare_price")
    private Double regularPrice;

    @Column(name = "sale_price")
    private Double discountPrice;

    @Column(name = "buying_price")
    private Double buyingPrice;

    private Integer quantity;

    @Column(columnDefinition = "TEXT")
    private String shortDescription;

    @Column(columnDefinition = "TEXT")
    private String productDescription;

    @Enumerated(EnumType.STRING)
    private ProductType productType;

    private Boolean published = true;

    private Boolean disableOutOfStock = true;

    @Column(columnDefinition = "TEXT")
    private String note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    @com.fasterxml.jackson.annotation.JsonIgnore
    private StaffAccount updatedBy;

    // Getters and setters for new fields
    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public Double getBuyingPrice() {
        return buyingPrice;
    }

    public void setBuyingPrice(Double buyingPrice) {
        this.buyingPrice = buyingPrice;
    }

    public Boolean getDisableOutOfStock() {
        return disableOutOfStock;
    }

    public void setDisableOutOfStock(Boolean disableOutOfStock) {
        this.disableOutOfStock = disableOutOfStock;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public StaffAccount getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(StaffAccount createdBy) {
        this.createdBy = createdBy;
    }

    public StaffAccount getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(StaffAccount updatedBy) {
        this.updatedBy = updatedBy;
    }

    public Product() {
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Double getRegularPrice() {
        return regularPrice;
    }

    public void setRegularPrice(Double regularPrice) {
        this.regularPrice = regularPrice;
    }

    public Double getDiscountPrice() {
        return discountPrice;
    }

    public void setDiscountPrice(Double discountPrice) {
        this.discountPrice = discountPrice;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    public String getProductDescription() {
        return productDescription;
    }

    public void setProductDescription(String productDescription) {
        this.productDescription = productDescription;
    }

    public ProductType getProductType() {
        return productType;
    }

    public void setProductType(ProductType productType) {
        this.productType = productType;
    }

    public Boolean getPublished() {
        return published;
    }

    public void setPublished(Boolean published) {
        this.published = published;
    }

    @Transient
    private Double averageRating = 5.0;

    public Double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(Double averageRating) {
        this.averageRating = averageRating;
    }
}