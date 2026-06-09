package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.ProductTagRequest;
import com.huakhanhduy.shopapp_backend.entity.ProductTag;

import java.util.List;
import java.util.UUID;

public interface ProductTagService {

    ProductTag create(ProductTagRequest request);

    List<ProductTag> getByTag(UUID tagId);

    List<ProductTag> getByProduct(UUID productId);

    void delete(UUID id);
}