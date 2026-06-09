package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "coupons")
public class Coupon extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    private Double discountValue;

    @Column(nullable = false, length = 50)
    private String discountType;

    @Column(nullable = false)
    private Double timesUsed = 0.0;

    private Double maxUsage;

    private Double orderAmountLimit;

    private Instant couponStartDate;

    private Instant couponEndDate;

    public Coupon() {}

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public Double getDiscountValue() { return discountValue; }
    public void setDiscountValue(Double discountValue) { this.discountValue = discountValue; }
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    public Double getTimesUsed() { return timesUsed; }
    public void setTimesUsed(Double timesUsed) { this.timesUsed = timesUsed; }
    public Double getMaxUsage() { return maxUsage; }
    public void setMaxUsage(Double maxUsage) { this.maxUsage = maxUsage; }
    public Double getOrderAmountLimit() { return orderAmountLimit; }
    public void setOrderAmountLimit(Double orderAmountLimit) { this.orderAmountLimit = orderAmountLimit; }
    public Instant getCouponStartDate() { return couponStartDate; }
    public void setCouponStartDate(Instant couponStartDate) { this.couponStartDate = couponStartDate; }
    public Instant getCouponEndDate() { return couponEndDate; }
    public void setCouponEndDate(Instant couponEndDate) { this.couponEndDate = couponEndDate; }
}
