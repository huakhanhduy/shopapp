package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "shipping_rates")
public class ShippingRate extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_zone_id", nullable = false)
    private ShippingZone shippingZone;

    @Column(length = 10)
    private String weightUnit;

    @Column(nullable = false)
    private Double minValue = 0.0;

    private Double maxValue;

    private Boolean noMax = true;

    @Column(nullable = false)
    private Double price = 0.0;

    public ShippingRate() {}

    public ShippingZone getShippingZone() { return shippingZone; }
    public void setShippingZone(ShippingZone shippingZone) { this.shippingZone = shippingZone; }
    public String getWeightUnit() { return weightUnit; }
    public void setWeightUnit(String weightUnit) { this.weightUnit = weightUnit; }
    public Double getMinValue() { return minValue; }
    public void setMinValue(Double minValue) { this.minValue = minValue; }
    public Double getMaxValue() { return maxValue; }
    public void setMaxValue(Double maxValue) { this.maxValue = maxValue; }
    public Boolean getNoMax() { return noMax; }
    public void setNoMax(Boolean noMax) { this.noMax = noMax; }
    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }
}
