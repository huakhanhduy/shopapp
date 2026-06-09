package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.*;
import com.huakhanhduy.shopapp_backend.service.PromotionShippingService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class PromotionShippingServiceImpl implements PromotionShippingService {

    private final CouponRepository couponRepository;
    private final ProductCouponRepository productCouponRepository;
    private final ProductRepository productRepository;
    private final CountryRepository countryRepository;
    private final ShippingZoneRepository shippingZoneRepository;
    private final ShippingRateRepository shippingRateRepository;

    public PromotionShippingServiceImpl(
            CouponRepository couponRepository,
            ProductCouponRepository productCouponRepository,
            ProductRepository productRepository,
            CountryRepository countryRepository,
            ShippingZoneRepository shippingZoneRepository,
            ShippingRateRepository shippingRateRepository
    ) {
        this.couponRepository = couponRepository;
        this.productCouponRepository = productCouponRepository;
        this.productRepository = productRepository;
        this.countryRepository = countryRepository;
        this.shippingZoneRepository = shippingZoneRepository;
        this.shippingRateRepository = shippingRateRepository;
    }

    @Override
    public Coupon createCoupon(Coupon coupon) {
        return couponRepository.save(coupon);
    }

    @Override
    public Coupon getCouponByCode(String code) {
        return couponRepository.findByCode(code).orElse(null);
    }

    @Override
    public ProductCoupon linkProductCoupon(UUID productId, UUID couponId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        Coupon coup = couponRepository.findById(couponId)
                .orElseThrow(() -> new RuntimeException("Coupon not found"));
        ProductCoupon link = new ProductCoupon();
        link.setProduct(prod);
        link.setCoupon(coup);
        return productCouponRepository.save(link);
    }

    @Override
    public List<Coupon> getCouponsForProduct(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        List<ProductCoupon> links = productCouponRepository.findByProduct(prod);
        List<Coupon> coupons = new ArrayList<>();
        for (ProductCoupon link : links) {
            coupons.add(link.getCoupon());
        }
        return coupons;
    }

    @Override
    public Country createCountry(Country country) {
        return countryRepository.save(country);
    }

    @Override
    public List<Country> getAllCountries() {
        return countryRepository.findAll();
    }

    @Override
    public ShippingZone createShippingZone(ShippingZone zone) {
        return shippingZoneRepository.save(zone);
    }

    @Override
    public List<ShippingZone> getAllShippingZones() {
        return shippingZoneRepository.findAll();
    }

    @Override
    public ShippingRate addShippingRate(UUID zoneId, ShippingRate rate) {
        ShippingZone zone = shippingZoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Shipping zone not found"));
        rate.setShippingZone(zone);
        return shippingRateRepository.save(rate);
    }

    @Override
    public List<ShippingRate> getRatesForZone(UUID zoneId) {
        ShippingZone zone = shippingZoneRepository.findById(zoneId)
                .orElseThrow(() -> new RuntimeException("Shipping zone not found"));
        return shippingRateRepository.findByShippingZone(zone);
    }
}
