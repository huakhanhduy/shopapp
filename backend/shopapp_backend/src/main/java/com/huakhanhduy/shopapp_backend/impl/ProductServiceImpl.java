package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductVariant;
import com.huakhanhduy.shopapp_backend.entity.Review;
import com.huakhanhduy.shopapp_backend.repository.ProductRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductVariantRepository;
import com.huakhanhduy.shopapp_backend.service.ProductService;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;
    private final com.huakhanhduy.shopapp_backend.repository.CategoryRepository categoryRepository;
    private final com.huakhanhduy.shopapp_backend.repository.ProductCategoryRepository productCategoryRepository;
    private final com.huakhanhduy.shopapp_backend.repository.ReviewRepository reviewRepository;

    public ProductServiceImpl(
            ProductRepository productRepository,
            ProductVariantRepository productVariantRepository,
            com.huakhanhduy.shopapp_backend.repository.CategoryRepository categoryRepository,
            com.huakhanhduy.shopapp_backend.repository.ProductCategoryRepository productCategoryRepository,
            com.huakhanhduy.shopapp_backend.repository.ReviewRepository reviewRepository
    ) {
        this.productRepository = productRepository;
        this.productVariantRepository = productVariantRepository;
        this.categoryRepository = categoryRepository;
        this.productCategoryRepository = productCategoryRepository;
        this.reviewRepository = reviewRepository;
    }

    @Override
    public List<Product> getAllProducts() {
        List<Product> list = productRepository.findAll();
        populateAverageRatings(list);
        return list;
    }

    @Override
    public Product getProductById(
            UUID id
    ) {

        Product p = productRepository
                .findById(id)
                .orElseThrow(
                        () -> new RuntimeException(
                                "Product not found"
                        )
                );
        populateAverageRating(p);
        return p;
    }

    @Override
    public Product createProduct(
            Product product
    ) {
        Product p = productRepository.save(product);
        populateAverageRating(p);
        return p;
    }

    @Override
    public Product updateProduct(
            UUID id,
            Product product
    ) {

        Product existing =
                productRepository
                        .findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Product not found"
                                )
                        );

        existing.setProductName(
                product.getProductName()
        );

        existing.setSku(
                product.getSku()
        );

        existing.setImageUrl(
                product.getImageUrl()
        );

        existing.setRegularPrice(
                product.getRegularPrice()
        );

        existing.setDiscountPrice(
                product.getDiscountPrice()
        );

        existing.setQuantity(
                product.getQuantity()
        );

        existing.setShortDescription(
                product.getShortDescription()
        );

        existing.setProductDescription(
                product.getProductDescription()
        );

        existing.setProductType(
                product.getProductType()
        );

        existing.setPublished(
                product.getPublished()
        );

        Product p = productRepository.save(existing);
        populateAverageRating(p);
        return p;
    }

    @Override
    public void deleteProduct(
            UUID id
    ) {

        Product existing =
                productRepository
                        .findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Product not found"
                                )
                        );

        productRepository.delete(existing);
    }

    @Override
    public List<Product> getRelatedProducts(UUID productId) {
        List<Product> list = productRepository.findRelatedProducts(productId);
        populateAverageRatings(list);
        return list;
    }

    @Override
    public List<Product> getProductsFiltered(String keyword, Double minPrice, Double maxPrice, String size, String color, String sort, UUID categoryId) {
        List<Product> products;

        if (categoryId != null) {
            List<com.huakhanhduy.shopapp_backend.entity.Category> allCategories = categoryRepository.findAll();
            List<UUID> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);

            for (com.huakhanhduy.shopapp_backend.entity.Category cat : allCategories) {
                if (cat.getParent() != null && cat.getParent().getId().equals(categoryId)) {
                    categoryIds.add(cat.getId());
                }
            }

            products = productCategoryRepository.findByCategoryIdIn(categoryIds).stream()
                    .map(com.huakhanhduy.shopapp_backend.entity.ProductCategory::getProduct)
                    .filter(p -> Boolean.TRUE.equals(p.getPublished()))
                    .distinct()
                    .toList();
        } else {
            products = productRepository.findByPublishedTrue();
        }

        // Lọc theo keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.toLowerCase().trim();
            products = products.stream()
                    .filter(p -> p.getProductName().toLowerCase().contains(kw) 
                            || (p.getShortDescription() != null && p.getShortDescription().toLowerCase().contains(kw))
                            || (p.getProductDescription() != null && p.getProductDescription().toLowerCase().contains(kw)))
                    .toList();
        }

        // Lọc theo khoảng giá
        if (minPrice != null) {
            products = products.stream()
                    .filter(p -> {
                        Double price = p.getDiscountPrice() != null ? p.getDiscountPrice() : p.getRegularPrice();
                        return price >= minPrice;
                    })
                    .toList();
        }
        if (maxPrice != null) {
            products = products.stream()
                    .filter(p -> {
                        Double price = p.getDiscountPrice() != null ? p.getDiscountPrice() : p.getRegularPrice();
                        return price <= maxPrice;
                    })
                    .toList();
        }

        // Lọc theo kích thước và màu sắc (kiểm tra biến thể)
        if ((size != null && !size.isEmpty()) || (color != null && !color.isEmpty())) {
            products = products.stream()
                    .filter(p -> {
                        List<ProductVariant> vars = productVariantRepository.findByProductId(p.getId());
                        return vars.stream().anyMatch(v -> {
                            boolean matchSize = size == null || size.isEmpty() || v.getSize().equalsIgnoreCase(size);
                            boolean matchColor = color == null || color.isEmpty() || v.getColor().equalsIgnoreCase(color);
                            return matchSize && matchColor;
                        });
                    })
                    .toList();
        }

        // Sắp xếp
        if (sort != null && !sort.isEmpty()) {
            products = new ArrayList<>(products);
            if (sort.equalsIgnoreCase("newest")) {
                products.sort((p1, p2) -> p2.getCreatedAt().compareTo(p1.getCreatedAt()));
            } else if (sort.equalsIgnoreCase("price_low")) {
                products.sort((p1, p2) -> {
                    Double price1 = p1.getDiscountPrice() != null ? p1.getDiscountPrice() : p1.getRegularPrice();
                    Double price2 = p2.getDiscountPrice() != null ? p2.getDiscountPrice() : p2.getRegularPrice();
                    return price1.compareTo(price2);
                });
            } else if (sort.equalsIgnoreCase("price_high")) {
                products.sort((p1, p2) -> {
                    Double price1 = p1.getDiscountPrice() != null ? p1.getDiscountPrice() : p1.getRegularPrice();
                    Double price2 = p2.getDiscountPrice() != null ? p2.getDiscountPrice() : p2.getRegularPrice();
                    return price2.compareTo(price1);
                });
            }
        }

        populateAverageRatings(products);
        return products;
    }

    @Override
    public List<Product> getVisualSearchResults() {
        List<Product> all = productRepository.findByPublishedTrue();
        populateAverageRatings(all);
        if (all.size() <= 3) {
            return all;
        }
        return all.subList(0, 3);
    }

    private void populateAverageRatings(List<Product> products) {
        if (products == null || products.isEmpty()) return;
        try {
            List<Object[]> ratings = reviewRepository.getAverageRatings();
            java.util.Map<UUID, Double> ratingMap = new java.util.HashMap<>();
            for (Object[] r : ratings) {
                if (r[0] != null && r[1] != null) {
                    ratingMap.put((UUID) r[0], (Double) r[1]);
                }
            }
            for (Product p : products) {
                if (ratingMap.containsKey(p.getId())) {
                    p.setAverageRating(ratingMap.get(p.getId()));
                }
            }
        } catch (Exception e) {
            // Ignore
        }
    }

    private void populateAverageRating(Product product) {
        if (product == null) return;
        try {
            List<Review> reviews = reviewRepository.findByProductIdOrderByCreatedAtDesc(product.getId());
            if (!reviews.isEmpty()) {
                double sum = 0;
                for (Review r : reviews) {
                    sum += r.getRating();
                }
                product.setAverageRating(sum / reviews.size());
            }
        } catch (Exception e) {
            // Ignore
        }
    }
}