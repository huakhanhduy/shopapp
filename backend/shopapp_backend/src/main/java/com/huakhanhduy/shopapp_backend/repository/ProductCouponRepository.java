package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Coupon;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductCoupon;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface ProductCouponRepository extends JpaRepository<ProductCoupon, UUID> {
    List<ProductCoupon> findByProduct(Product product);
    List<ProductCoupon> findByCoupon(Coupon coupon);
}
