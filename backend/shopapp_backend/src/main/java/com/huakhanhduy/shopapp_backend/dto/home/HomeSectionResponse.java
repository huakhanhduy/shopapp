package com.huakhanhduy.shopapp_backend.dto.home;

import com.huakhanhduy.shopapp_backend.entity.Product;

import java.util.List;

public class HomeSectionResponse {

    private String tagName;

    private String subtitle;

    private List<Product> products;

    public HomeSectionResponse() {
    }

    public String getTagName() {
        return tagName;
    }

    public void setTagName(String tagName) {
        this.tagName = tagName;
    }

    public String getSubtitle() {
        return subtitle;
    }

    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    public List<Product> getProducts() {
        return products;
    }

    public void setProducts(List<Product> products) {
        this.products = products;
    }
}