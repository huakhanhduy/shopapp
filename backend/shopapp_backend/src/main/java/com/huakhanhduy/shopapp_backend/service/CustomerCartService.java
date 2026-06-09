package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.*;
import java.util.List;
import java.util.UUID;

public interface CustomerCartService {
    // Customer
    Customer registerCustomer(Customer customer);
    Customer getCustomerByEmail(String email);
    Customer getCustomerById(UUID id);

    // Customer Address
    CustomerAddress addAddress(UUID customerId, CustomerAddress address);
    List<CustomerAddress> getCustomerAddresses(UUID customerId);

    // Cart
    Cart getOrCreateCart(UUID customerId);
    CartItem addToCart(UUID customerId, UUID productId, Integer quantity, String size, String color);
    List<CartItem> getCartItems(UUID customerId);
    void updateCartItemQuantity(UUID cartItemId, Integer quantity);
    void removeFromCart(UUID cartItemId);
    void clearCart(UUID customerId);

    // Wishlist
    void addToWishlist(UUID customerId, UUID productId);
    void removeFromWishlist(UUID customerId, UUID productId);
    List<Product> getWishlist(UUID customerId);
}
