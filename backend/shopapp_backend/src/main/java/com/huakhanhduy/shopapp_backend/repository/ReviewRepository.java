package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    List<Review> findByProductIdOrderByCreatedAtDesc(UUID productId);

    List<Review> findByProductIdAndCustomerEmail(UUID productId, String customerEmail);

    @org.springframework.data.jpa.repository.Query("SELECT r.product.id, AVG(cast(r.rating as double)) FROM Review r GROUP BY r.product.id")
    List<Object[]> getAverageRatings();

}
