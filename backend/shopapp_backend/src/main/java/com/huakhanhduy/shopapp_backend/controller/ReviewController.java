package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.Review;
import com.huakhanhduy.shopapp_backend.service.ReviewService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@CrossOrigin("*")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping("/{productId}/reviews")
    public ResponseEntity<List<Review>> getReviews(
            @PathVariable UUID productId
    ) {
        return ResponseEntity.ok(reviewService.getReviewsByProductId(productId));
    }

    @PostMapping(value = "/{productId}/reviews", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Review> createReview(
            @PathVariable UUID productId,
            @RequestParam("rating") int rating,
            @RequestParam("comment") String comment,
            @RequestParam(value = "images", required = false) List<MultipartFile> images,
            Principal principal
    ) {
        if (principal == null) {
            throw new RuntimeException("Unauthorized: User not logged in");
        }
        String userEmail = principal.getName();
        return ResponseEntity.ok(reviewService.createReview(productId, userEmail, rating, comment, images));
    }
}
