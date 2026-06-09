package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.*;
import com.huakhanhduy.shopapp_backend.service.ProductInventoryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ProductInventoryServiceImpl implements ProductInventoryService {

    private final ProductRepository productRepository;
    private final AttributeRepository attributeRepository;
    private final AttributeValueRepository attributeValueRepository;
    private final ProductAttributeRepository productAttributeRepository;
    private final ProductAttributeValueRepository productAttributeValueRepository;
    private final GalleryRepository galleryRepository;
    private final ProductShippingInfoRepository productShippingInfoRepository;
    private final SupplierRepository supplierRepository;
    private final ProductSupplierRepository productSupplierRepository;
    private final VariantOptionRepository variantOptionRepository;
    private final VariantRepository variantRepository;
    private final VariantValueRepository variantValueRepository;

    public ProductInventoryServiceImpl(
            ProductRepository productRepository,
            AttributeRepository attributeRepository,
            AttributeValueRepository attributeValueRepository,
            ProductAttributeRepository productAttributeRepository,
            ProductAttributeValueRepository productAttributeValueRepository,
            GalleryRepository galleryRepository,
            ProductShippingInfoRepository productShippingInfoRepository,
            SupplierRepository supplierRepository,
            ProductSupplierRepository productSupplierRepository,
            VariantOptionRepository variantOptionRepository,
            VariantRepository variantRepository,
            VariantValueRepository variantValueRepository
    ) {
        this.productRepository = productRepository;
        this.attributeRepository = attributeRepository;
        this.attributeValueRepository = attributeValueRepository;
        this.productAttributeRepository = productAttributeRepository;
        this.productAttributeValueRepository = productAttributeValueRepository;
        this.galleryRepository = galleryRepository;
        this.productShippingInfoRepository = productShippingInfoRepository;
        this.supplierRepository = supplierRepository;
        this.productSupplierRepository = productSupplierRepository;
        this.variantOptionRepository = variantOptionRepository;
        this.variantRepository = variantRepository;
        this.variantValueRepository = variantValueRepository;
    }

    @Override
    public Attribute createAttribute(Attribute attribute) {
        return attributeRepository.save(attribute);
    }

    @Override
    public List<Attribute> getAllAttributes() {
        return attributeRepository.findAll();
    }

    @Override
    public AttributeValue createAttributeValue(UUID attributeId, AttributeValue value) {
        Attribute attr = attributeRepository.findById(attributeId)
                .orElseThrow(() -> new RuntimeException("Attribute not found"));
        value.setAttribute(attr);
        return attributeValueRepository.save(value);
    }

    @Override
    public List<AttributeValue> getAttributeValues(UUID attributeId) {
        Attribute attr = attributeRepository.findById(attributeId)
                .orElseThrow(() -> new RuntimeException("Attribute not found"));
        return attributeValueRepository.findByAttribute(attr);
    }

    @Override
    public Gallery addImageToGallery(UUID productId, String imageUrl, String placeholder, Boolean isThumbnail) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        Gallery gallery = new Gallery();
        gallery.setProduct(prod);
        gallery.setImage(imageUrl);
        gallery.setPlaceholder(placeholder);
        gallery.setIsThumbnail(isThumbnail);
        return galleryRepository.save(gallery);
    }

    @Override
    public List<Gallery> getProductGallery(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return galleryRepository.findByProduct(prod);
    }

    @Override
    public ProductShippingInfo saveShippingInfo(UUID productId, ProductShippingInfo info) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        info.setProduct(prod);
        return productShippingInfoRepository.save(info);
    }

    @Override
    public ProductShippingInfo getShippingInfo(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return productShippingInfoRepository.findByProduct(prod).orElse(null);
    }

    @Override
    public Supplier createSupplier(Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    @Override
    public List<Supplier> getAllSuppliers() {
        return supplierRepository.findAll();
    }

    @Override
    public ProductSupplier linkProductSupplier(UUID productId, UUID supplierId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        Supplier supp = supplierRepository.findById(supplierId)
                .orElseThrow(() -> new RuntimeException("Supplier not found"));
        ProductSupplier link = new ProductSupplier();
        link.setProduct(prod);
        link.setSupplier(supp);
        return productSupplierRepository.save(link);
    }

    @Override
    public List<Supplier> getProductSuppliers(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        List<ProductSupplier> links = productSupplierRepository.findByProduct(prod);
        List<Supplier> suppliers = new ArrayList<>();
        for (ProductSupplier link : links) {
            suppliers.add(link.getSupplier());
        }
        return suppliers;
    }

    @Override
    public VariantOption createVariantOption(VariantOption option) {
        return variantOptionRepository.save(option);
    }

    @Override
    public List<VariantOption> getProductVariantOptions(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return variantOptionRepository.findByProduct(prod);
    }

    @Override
    public Variant createVariant(Variant variant) {
        return variantRepository.save(variant);
    }

    @Override
    public List<Variant> getProductVariants(UUID productId) {
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return variantRepository.findByProduct(prod);
    }
}
