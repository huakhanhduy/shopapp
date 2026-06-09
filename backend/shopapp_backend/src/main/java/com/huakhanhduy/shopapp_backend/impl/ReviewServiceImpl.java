package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.Customer;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.Review;
import com.huakhanhduy.shopapp_backend.repository.CustomerRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductRepository;
import com.huakhanhduy.shopapp_backend.repository.ReviewRepository;
import com.huakhanhduy.shopapp_backend.service.ReviewService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final ProductRepository productRepository;
    private final CustomerRepository customerRepository;

    public ReviewServiceImpl(
            ReviewRepository reviewRepository,
            ProductRepository productRepository,
            CustomerRepository customerRepository
    ) {
        this.reviewRepository = reviewRepository;
        this.productRepository = productRepository;
        this.customerRepository = customerRepository;
    }

    @Override
    public List<Review> getReviewsByProductId(UUID productId) {
        return reviewRepository.findByProductIdOrderByCreatedAtDesc(productId);
    }

    @Override
    public Review createReview(UUID productId, String userEmail, int rating, String comment, List<MultipartFile> images) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Customer customer = customerRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        List<Review> existingReviews = reviewRepository.findByProductIdAndCustomerEmail(productId, userEmail);
        Review review;
        if (!existingReviews.isEmpty()) {
            review = existingReviews.get(0);
        } else {
            review = new Review();
            review.setProduct(product);
            review.setCustomer(customer);
        }

        review.setRating(rating);
        review.setComment(comment);

        if (images != null && !images.isEmpty()) {
            List<String> imagePaths = new ArrayList<>();
            // Frontend assets uploads directory path relative to the backend's working directory
            Path uploadDir = Paths.get("../../frontend/shopapp_frontend/assets/uploads/");
            Path buildWebUploadDir = Paths.get("../../frontend/shopapp_frontend/build/web/assets/uploads/");
            try {
                if (!Files.exists(uploadDir)) {
                    Files.createDirectories(uploadDir);
                }
                if (!Files.exists(buildWebUploadDir)) {
                    Files.createDirectories(buildWebUploadDir);
                }

                for (MultipartFile file : images) {
                    if (file == null || file.isEmpty()) {
                        continue;
                    }
                    String originalFilename = file.getOriginalFilename();
                    String extension = "";
                    if (originalFilename != null && originalFilename.contains(".")) {
                        extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                    } else {
                        String contentType = file.getContentType();
                        if (contentType != null) {
                            if (contentType.equalsIgnoreCase("image/jpeg") || contentType.equalsIgnoreCase("image/jpg")) {
                                extension = ".jpg";
                            } else if (contentType.equalsIgnoreCase("image/png")) {
                                extension = ".png";
                            } else if (contentType.equalsIgnoreCase("image/gif")) {
                                extension = ".gif";
                            } else if (contentType.equalsIgnoreCase("image/webp")) {
                                extension = ".webp";
                            }
                        }
                    }
                    String uniqueFilename = UUID.randomUUID().toString() + extension;
                    
                    // Save to root assets/uploads
                    Path filePath = uploadDir.resolve(uniqueFilename);
                    Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
                    
                    // Save to build/web/assets/uploads
                    try {
                        Path buildWebFilePath = buildWebUploadDir.resolve(uniqueFilename);
                        Files.copy(filePath, buildWebFilePath, StandardCopyOption.REPLACE_EXISTING);
                    } catch (Exception e) {
                        // Ignore if build/web folder is locked or not yet generated
                    }
                    
                    imagePaths.add("assets/uploads/" + uniqueFilename);
                }
                review.setImages(imagePaths);
            } catch (IOException e) {
                throw new RuntimeException("Could not upload review images: " + e.getMessage());
            }
        }

        return reviewRepository.save(review);
    }
}
