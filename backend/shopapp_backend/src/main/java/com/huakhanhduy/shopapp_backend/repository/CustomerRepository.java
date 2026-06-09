package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, UUID> {
    Optional<Customer> findByEmail(String email);
}
