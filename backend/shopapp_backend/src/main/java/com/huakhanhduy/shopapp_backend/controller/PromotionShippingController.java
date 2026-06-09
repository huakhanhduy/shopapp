package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.service.PromotionShippingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/promotions-shipping")
public class PromotionShippingController {

    private final PromotionShippingService promotionShippingService;

    public PromotionShippingController(PromotionShippingService promotionShippingService) {
        this.promotionShippingService = promotionShippingService;
    }

    @PostMapping("/coupons")
    public ResponseEntity<Coupon> createCoupon(@RequestBody Coupon coupon) {
        return ResponseEntity.ok(promotionShippingService.createCoupon(coupon));
    }

    @GetMapping("/coupons/{code}")
    public ResponseEntity<Coupon> getCouponByCode(@PathVariable String code) {
        Coupon coup = promotionShippingService.getCouponByCode(code);
        if (coup == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(coup);
    }

    @PostMapping("/products/{productId}/coupons/{couponId}")
    public ResponseEntity<ProductCoupon> linkProductCoupon(@PathVariable UUID productId, @PathVariable UUID couponId) {
        return ResponseEntity.ok(promotionShippingService.linkProductCoupon(productId, couponId));
    }

    @GetMapping("/products/{productId}/coupons")
    public ResponseEntity<List<Coupon>> getCouponsForProduct(@PathVariable UUID productId) {
        return ResponseEntity.ok(promotionShippingService.getCouponsForProduct(productId));
    }

    @PostMapping("/countries")
    public ResponseEntity<Country> createCountry(@RequestBody Country country) {
        return ResponseEntity.ok(promotionShippingService.createCountry(country));
    }

    @GetMapping("/countries")
    public ResponseEntity<List<Country>> getAllCountries() {
        return ResponseEntity.ok(promotionShippingService.getAllCountries());
    }

    @PostMapping("/zones")
    public ResponseEntity<ShippingZone> createShippingZone(@RequestBody ShippingZone zone) {
        return ResponseEntity.ok(promotionShippingService.createShippingZone(zone));
    }

    @GetMapping("/zones")
    public ResponseEntity<List<ShippingZone>> getAllShippingZones() {
        return ResponseEntity.ok(promotionShippingService.getAllShippingZones());
    }

    @PostMapping("/zones/{zoneId}/rates")
    public ResponseEntity<ShippingRate> addShippingRate(@PathVariable UUID zoneId, @RequestBody ShippingRate rate) {
        return ResponseEntity.ok(promotionShippingService.addShippingRate(zoneId, rate));
    }

    @GetMapping("/zones/{zoneId}/rates")
    public ResponseEntity<List<ShippingRate>> getRatesForZone(@PathVariable UUID zoneId) {
        return ResponseEntity.ok(promotionShippingService.getRatesForZone(zoneId));
    }
}
