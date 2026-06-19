package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.Review;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface ReviewService {

    List<Review> getReviewsByProductId(UUID productId);

    Review createReview(UUID productId, String userEmail, int rating, String comment, List<MultipartFile> images);

    List<Review> getReviewsByCustomerEmail(String customerEmail);

}
