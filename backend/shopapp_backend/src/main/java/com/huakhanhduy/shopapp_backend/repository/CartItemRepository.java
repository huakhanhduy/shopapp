package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.Cart;
import com.huakhanhduy.shopapp_backend.entity.CartItem;
import com.huakhanhduy.shopapp_backend.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CartItemRepository extends JpaRepository<CartItem, UUID> {
    @Query("SELECT ci FROM CartItem ci JOIN FETCH ci.product WHERE ci.cart = :cart")
    List<CartItem> findByCart(@Param("cart") Cart cart);
    Optional<CartItem> findByCartAndProduct(Cart cart, Product product);
    Optional<CartItem> findByCartAndProductAndSizeAndColor(Cart cart, Product product, String size, String color);
    void deleteByCart(Cart cart);
}
