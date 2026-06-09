package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.*;
import java.util.List;
import java.util.UUID;

public interface PromotionShippingService {
    // Coupons
    Coupon createCoupon(Coupon coupon);
    Coupon getCouponByCode(String code);
    ProductCoupon linkProductCoupon(UUID productId, UUID couponId);
    List<Coupon> getCouponsForProduct(UUID productId);

    // Countries
    Country createCountry(Country country);
    List<Country> getAllCountries();

    // Shipping Zones & Rates
    ShippingZone createShippingZone(ShippingZone zone);
    List<ShippingZone> getAllShippingZones();
    ShippingRate addShippingRate(UUID zoneId, ShippingRate rate);
    List<ShippingRate> getRatesForZone(UUID zoneId);
}
