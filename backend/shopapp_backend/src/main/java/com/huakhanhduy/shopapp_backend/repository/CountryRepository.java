package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Country;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CountryRepository extends JpaRepository<Country, Integer> {
    Optional<Country> findByIso(String iso);
}
