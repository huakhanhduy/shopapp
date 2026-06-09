package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "attributes")
public class Attribute extends BaseEntity {

    @Column(nullable = false, length = 255)
    private String attributeName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private StaffAccount updatedBy;

    public Attribute() {}

    public String getAttributeName() { return attributeName; }
    public void setAttributeName(String attributeName) { this.attributeName = attributeName; }
    public StaffAccount getCreatedBy() { return createdBy; }
    public void setCreatedBy(StaffAccount createdBy) { this.createdBy = createdBy; }
    public StaffAccount getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(StaffAccount updatedBy) { this.updatedBy = updatedBy; }
}
