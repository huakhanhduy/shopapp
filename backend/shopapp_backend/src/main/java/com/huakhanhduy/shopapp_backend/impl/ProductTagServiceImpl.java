package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.ProductTagRequest;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.ProductTag;
import com.huakhanhduy.shopapp_backend.entity.Tag;
import com.huakhanhduy.shopapp_backend.repository.ProductRepository;
import com.huakhanhduy.shopapp_backend.repository.ProductTagRepository;
import com.huakhanhduy.shopapp_backend.repository.TagRepository;
import com.huakhanhduy.shopapp_backend.service.ProductTagService;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ProductTagServiceImpl implements ProductTagService {

    private final ProductTagRepository productTagRepository;
    private final ProductRepository productRepository;
    private final TagRepository tagRepository;

    public ProductTagServiceImpl(
            ProductTagRepository productTagRepository,
            ProductRepository productRepository,
            TagRepository tagRepository
    ) {
        this.productTagRepository = productTagRepository;
        this.productRepository = productRepository;
        this.tagRepository = tagRepository;
    }

    @Override
    public ProductTag create(
            ProductTagRequest request
    ) {

        Product product =
                productRepository
                        .findById(request.getProductId())
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Product not found"
                                )
                        );

        Tag tag =
                tagRepository
                        .findById(request.getTagId())
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Tag not found"
                                )
                        );

        ProductTag productTag = new ProductTag();

        productTag.setProduct(product);
        productTag.setTag(tag);

        return productTagRepository.save(productTag);
    }

    @Override
    public List<ProductTag> getByTag(
            UUID tagId
    ) {

        Tag tag =
                tagRepository
                        .findById(tagId)
                        .orElseThrow();

        return productTagRepository.findByTag(tag);
    }

    @Override
    public List<ProductTag> getByProduct(
            UUID productId
    ) {

        Product product =
                productRepository
                        .findById(productId)
                        .orElseThrow();

        return productTagRepository.findByProduct(product);
    }

    @Override
    public void delete(
            UUID id
    ) {

        productTagRepository.deleteById(id);
    }
}