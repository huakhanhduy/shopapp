package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "order_statuses")
public class OrderStatusEntity extends BaseEntity {

    @Column(nullable = false, length = 255)
    private String statusName;

    @Column(nullable = false, length = 50)
    private String color;

    @Column(length = 10)
    private String privacy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private StaffAccount updatedBy;

    public OrderStatusEntity() {}

    public String getStatusName() { return statusName; }
    public void setStatusName(String statusName) { this.statusName = statusName; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public String getPrivacy() { return privacy; }
    public void setPrivacy(String privacy) { this.privacy = privacy; }
    public StaffAccount getCreatedBy() { return createdBy; }
    public void setCreatedBy(StaffAccount createdBy) { this.createdBy = createdBy; }
    public StaffAccount getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(StaffAccount updatedBy) { this.updatedBy = updatedBy; }
}
