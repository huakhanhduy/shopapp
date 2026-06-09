package com.huakhanhduy.shopapp_backend.dto;

import java.util.UUID;

public class ProductTagRequest {

    private UUID productId;

    private UUID tagId;

    public ProductTagRequest() {
    }

    public UUID getProductId() {
        return productId;
    }

    public void setProductId(UUID productId) {
        this.productId = productId;
    }

    public UUID getTagId() {
        return tagId;
    }

    public void setTagId(UUID tagId) {
        this.tagId = tagId;
    }
}