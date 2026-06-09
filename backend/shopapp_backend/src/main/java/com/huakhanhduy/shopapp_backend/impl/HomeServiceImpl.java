package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.home.HomeResponse;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.repository.CategoryRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductRepository;
import com.huakhanhduy.shopapp_backend.repository.TagRepository;
import com.huakhanhduy.shopapp_backend.service.HomeService;
import com.huakhanhduy.shopapp_backend.dto.home.HomeSectionResponse;
import com.huakhanhduy.shopapp_backend.entity.ProductTag;
import com.huakhanhduy.shopapp_backend.entity.Tag;
import com.huakhanhduy.shopapp_backend.repository.ProductTagRepository;
import com.huakhanhduy.shopapp_backend.repository.ReviewRepository;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HomeServiceImpl implements HomeService {

        private final CategoryRepository categoryRepository;
        private final ProductRepository productRepository;
        private final TagRepository tagRepository;
        private final ProductTagRepository productTagRepository;
        private final ReviewRepository reviewRepository;

        public HomeServiceImpl(
                        CategoryRepository categoryRepository,
                        ProductRepository productRepository,
                        TagRepository tagRepository,
                        ProductTagRepository productTagRepository,
                        ReviewRepository reviewRepository) {
                this.categoryRepository = categoryRepository;
                this.productRepository = productRepository;
                this.tagRepository = tagRepository;
                this.productTagRepository = productTagRepository;
                this.reviewRepository = reviewRepository;
        }

        @Override
        public HomeResponse getHome() {

                HomeResponse response = new HomeResponse();

                response.setBanners(
                                List.of(
                                                "assets/images/banner1.png",
                                                "assets/images/banner2.png"));

                HomeSectionResponse saleSection = buildSection(
                                "Sale",
                                "Super summer sale");

                HomeSectionResponse newSection = buildSection(
                                "Mới Về",
                                "You've never seen it before");

                HomeSectionResponse trendSection = buildSection(
                                "Hot Trend",
                                "Trending now");

                response.setSections(
                                List.of(
                                                saleSection,
                                                newSection,
                                                trendSection));

                return response;
        }

        private HomeSectionResponse buildSection(
                        String tagName,
                        String subtitle) {

                HomeSectionResponse section = new HomeSectionResponse();

                section.setTagName(tagName);
                section.setSubtitle(subtitle);

                Tag tag = tagRepository
                                .findByTagName(tagName)
                                .orElse(null);

                if (tag == null) {

                        section.setProducts(
                                        List.of());

                        return section;
                }

                List<Product> products = productTagRepository
                                .findByTag(tag)
                                .stream()
                                .map(ProductTag::getProduct)
                                .toList();

                populateAverageRatings(products);
                section.setProducts(products);

                return section;
        }

        private void populateAverageRatings(List<Product> products) {
                if (products == null || products.isEmpty()) return;
                try {
                        List<Object[]> ratings = reviewRepository.getAverageRatings();
                        java.util.Map<java.util.UUID, Double> ratingMap = new java.util.HashMap<>();
                        for (Object[] r : ratings) {
                                if (r[0] != null && r[1] != null) {
                                        ratingMap.put((java.util.UUID) r[0], (Double) r[1]);
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
}