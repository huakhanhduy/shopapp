package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "countries")
public class Country {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 2)
    private String iso;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(name = "upper_name", nullable = false, length = 80)
    private String upperName;

    @Column(length = 3)
    private String iso3;

    private Short numCode;

    @Column(nullable = false)
    private Integer phoneCode;

    public Country() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getIso() { return iso; }
    public void setIso(String iso) { this.iso = iso; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getUpperName() { return upperName; }
    public void setUpperName(String upperName) { this.upperName = upperName; }
    public String getIso3() { return iso3; }
    public void setIso3(String iso3) { this.iso3 = iso3; }
    public Short getNumCode() { return numCode; }
    public void setNumCode(Short numCode) { this.numCode = numCode; }
    public Integer getPhoneCode() { return phoneCode; }
    public void setPhoneCode(Integer phoneCode) { this.phoneCode = phoneCode; }
}
