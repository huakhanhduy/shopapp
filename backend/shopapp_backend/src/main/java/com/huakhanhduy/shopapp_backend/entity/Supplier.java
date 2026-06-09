package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "suppliers")
public class Supplier extends BaseEntity {

    @Column(nullable = false, length = 255)
    private String supplierName;

    @Column(length = 255)
    private String company;

    @Column(length = 255)
    private String phoneNumber;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String addressLine1;

    @Column(columnDefinition = "TEXT")
    private String addressLine2;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "country_id", nullable = false)
    private Country country;

    @Column(length = 255)
    private String city;

    @Column(columnDefinition = "TEXT")
    private String note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private StaffAccount updatedBy;

    public Supplier() {}

    public String getSupplierName() { return supplierName; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAddressLine1() { return addressLine1; }
    public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }
    public String getAddressLine2() { return addressLine2; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }
    public Country getCountry() { return country; }
    public void setCountry(Country country) { this.country = country; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public StaffAccount getCreatedBy() { return createdBy; }
    public void setCreatedBy(StaffAccount createdBy) { this.createdBy = createdBy; }
    public StaffAccount getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(StaffAccount updatedBy) { this.updatedBy = updatedBy; }
}
