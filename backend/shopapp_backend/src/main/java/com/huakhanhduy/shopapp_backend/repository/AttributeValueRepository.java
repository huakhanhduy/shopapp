package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Attribute;
import com.huakhanhduy.shopapp_backend.entity.AttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AttributeValueRepository extends JpaRepository<AttributeValue, UUID> {
    List<AttributeValue> findByAttribute(Attribute attribute);
}
