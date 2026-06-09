package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "product_shipping_info")
public class ProductShippingInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    private Double weight = 0.0;

    @Column(length = 10)
    private String weightUnit;

    private Double volume = 0.0;

    @Column(length = 10)
    private String volumeUnit;

    private Double dimensionWidth = 0.0;
    private Double dimensionHeight = 0.0;
    private Double dimensionDepth = 0.0;

    @Column(length = 10)
    private String dimensionUnit;

    public ProductShippingInfo() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
    public String getWeightUnit() { return weightUnit; }
    public void setWeightUnit(String weightUnit) { this.weightUnit = weightUnit; }
    public Double getVolume() { return volume; }
    public void setVolume(Double volume) { this.volume = volume; }
    public String getVolumeUnit() { return volumeUnit; }
    public void setVolumeUnit(String volumeUnit) { this.volumeUnit = volumeUnit; }
    public Double getDimensionWidth() { return dimensionWidth; }
    public void setDimensionWidth(Double dimensionWidth) { this.dimensionWidth = dimensionWidth; }
    public Double getDimensionHeight() { return dimensionHeight; }
    public void setDimensionHeight(Double dimensionHeight) { this.dimensionHeight = dimensionHeight; }
    public Double getDimensionDepth() { return dimensionDepth; }
    public void setDimensionDepth(Double dimensionDepth) { this.dimensionDepth = dimensionDepth; }
    public String getDimensionUnit() { return dimensionUnit; }
    public void setDimensionUnit(String dimensionUnit) { this.dimensionUnit = dimensionUnit; }
}
