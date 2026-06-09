package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "shipping_zones")
public class ShippingZone extends BaseEntity {

    @Column(nullable = false, length = 255)
    private String name;

    @Column(name = "display_name", nullable = false, length = 255)
    private String displayName;

    private Boolean active = false;

    private Boolean freeShipping = false;

    @Column(length = 64)
    private String rateType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private StaffAccount updatedBy;

    public ShippingZone() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public Boolean getFreeShipping() { return freeShipping; }
    public void setFreeShipping(Boolean freeShipping) { this.freeShipping = freeShipping; }
    public String getRateType() { return rateType; }
    public void setRateType(String rateType) { this.rateType = rateType; }
    public StaffAccount getCreatedBy() { return createdBy; }
    public void setCreatedBy(StaffAccount createdBy) { this.createdBy = createdBy; }
    public StaffAccount getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(StaffAccount updatedBy) { this.updatedBy = updatedBy; }
}
