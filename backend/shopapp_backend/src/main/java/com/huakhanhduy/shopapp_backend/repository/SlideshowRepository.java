package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Slideshow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface SlideshowRepository extends JpaRepository<Slideshow, UUID> {
    List<Slideshow> findByPublishedOrderByDisplayOrderAsc(Boolean published);
}
