package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "promo_codes")
public class PromoCode extends BaseEntity {

    @Column(nullable = false, unique = true)
    private String code;

    private Double discountAmount;

    private Integer discountPercent;

    private Instant expiryDate;

    private Boolean active = true;

    public PromoCode() {
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(Double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public Integer getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(Integer discountPercent) {
        this.discountPercent = discountPercent;
    }

    public Instant getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Instant expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
