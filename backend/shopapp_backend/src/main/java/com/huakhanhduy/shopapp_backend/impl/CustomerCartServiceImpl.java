package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.*;
import com.huakhanhduy.shopapp_backend.service.CustomerCartService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class CustomerCartServiceImpl implements CustomerCartService {

    private final CustomerRepository customerRepository;
    private final CustomerAddressRepository customerAddressRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final PasswordEncoder passwordEncoder;
    private final WishlistItemRepository wishlistItemRepository;

    public CustomerCartServiceImpl(
            CustomerRepository customerRepository,
            CustomerAddressRepository customerAddressRepository,
            CartRepository cartRepository,
            CartItemRepository cartItemRepository,
            ProductRepository productRepository,
            PasswordEncoder passwordEncoder,
            WishlistItemRepository wishlistItemRepository
    ) {
        this.customerRepository = customerRepository;
        this.customerAddressRepository = customerAddressRepository;
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.passwordEncoder = passwordEncoder;
        this.wishlistItemRepository = wishlistItemRepository;
    }

    @Override
    public Customer registerCustomer(Customer customer) {
        customer.setPasswordHash(passwordEncoder.encode(customer.getPasswordHash()));
        return customerRepository.save(customer);
    }

    @Override
    public Customer getCustomerByEmail(String email) {
        return customerRepository.findByEmail(email).orElse(null);
    }

    @Override
    public Customer getCustomerById(UUID id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
    }

    @Override
    public CustomerAddress addAddress(UUID customerId, CustomerAddress address) {
        Customer cust = getCustomerById(customerId);
        address.setCustomer(cust);
        return customerAddressRepository.save(address);
    }

    @Override
    public List<CustomerAddress> getCustomerAddresses(UUID customerId) {
        Customer cust = getCustomerById(customerId);
        return customerAddressRepository.findByCustomer(cust);
    }

    @Override
    public Cart getOrCreateCart(UUID customerId) {
        Customer cust = getCustomerById(customerId);
        return cartRepository.findByCustomer(cust)
                .orElseGet(() -> {
                    Cart newCart = new Cart();
                    newCart.setCustomer(cust);
                    return cartRepository.save(newCart);
                });
    }

    @Override
    public CartItem addToCart(UUID customerId, UUID productId, Integer quantity, String size, String color) {
        Cart cart = getOrCreateCart(customerId);
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        CartItem item = cartItemRepository.findByCartAndProductAndSizeAndColor(cart, prod, size, color)
                .orElseGet(() -> {
                    CartItem newItem = new CartItem();
                    newItem.setCart(cart);
                    newItem.setProduct(prod);
                    newItem.setSize(size);
                    newItem.setColor(color);
                    newItem.setQuantity(0);
                    return newItem;
                });

        item.setQuantity(item.getQuantity() + quantity);
        return cartItemRepository.save(item);
    }

    @Override
    public List<CartItem> getCartItems(UUID customerId) {
        Cart cart = getOrCreateCart(customerId);
        return cartItemRepository.findByCart(cart);
    }

    @Override
    public void updateCartItemQuantity(UUID cartItemId, Integer quantity) {
        CartItem item = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        if (quantity <= 0) {
            cartItemRepository.delete(item);
        } else {
            item.setQuantity(quantity);
            cartItemRepository.save(item);
        }
    }

    @Override
    public void removeFromCart(UUID cartItemId) {
        cartItemRepository.deleteById(cartItemId);
    }

    @Override
    public void clearCart(UUID customerId) {
        Cart cart = getOrCreateCart(customerId);
        cartItemRepository.deleteByCart(cart);
    }

    @Override
    public void addToWishlist(UUID customerId, UUID productId) {
        Customer cust = getCustomerById(customerId);
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        if (wishlistItemRepository.findByCustomerAndProduct(cust, prod).isEmpty()) {
            WishlistItem item = new WishlistItem(cust, prod);
            wishlistItemRepository.save(item);
        }
    }

    @Override
    public void removeFromWishlist(UUID customerId, UUID productId) {
        Customer cust = getCustomerById(customerId);
        Product prod = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        wishlistItemRepository.deleteByCustomerAndProduct(cust, prod);
    }

    @Override
    public List<Product> getWishlist(UUID customerId) {
        Customer cust = getCustomerById(customerId);
        return wishlistItemRepository.findByCustomer(cust).stream()
                .map(WishlistItem::getProduct)
                .toList();
    }
}
