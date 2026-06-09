package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Customer;
import com.huakhanhduy.shopapp_backend.entity.Product;
import com.huakhanhduy.shopapp_backend.entity.WishlistItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WishlistItemRepository extends JpaRepository<WishlistItem, UUID> {
    @Query("SELECT w FROM WishlistItem w JOIN FETCH w.product WHERE w.customer = :customer")
    List<WishlistItem> findByCustomer(@Param("customer") Customer customer);
    Optional<WishlistItem> findByCustomerAndProduct(Customer customer, Product product);
    void deleteByCustomer(Customer customer);
    void deleteByCustomerAndProduct(Customer customer, Product product);
}
