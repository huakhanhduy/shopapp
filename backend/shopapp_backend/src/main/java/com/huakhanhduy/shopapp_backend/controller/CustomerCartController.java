package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.service.CustomerCartService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/customers")
public class CustomerCartController {

    private final CustomerCartService customerCartService;

    public CustomerCartController(CustomerCartService customerCartService) {
        this.customerCartService = customerCartService;
    }

    @PostMapping("/register")
    public ResponseEntity<Customer> registerCustomer(@RequestBody Customer customer) {
        return ResponseEntity.ok(customerCartService.registerCustomer(customer));
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<Customer> getCustomerByEmail(@PathVariable String email) {
        Customer cust = customerCartService.getCustomerByEmail(email);
        if (cust == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(cust);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomerById(@PathVariable UUID id) {
        return ResponseEntity.ok(customerCartService.getCustomerById(id));
    }

    @PostMapping("/{id}/addresses")
    public ResponseEntity<CustomerAddress> addAddress(@PathVariable UUID id, @RequestBody CustomerAddress address) {
        return ResponseEntity.ok(customerCartService.addAddress(id, address));
    }

    @GetMapping("/{id}/addresses")
    public ResponseEntity<List<CustomerAddress>> getCustomerAddresses(@PathVariable UUID id) {
        return ResponseEntity.ok(customerCartService.getCustomerAddresses(id));
    }

    @GetMapping("/{id}/cart")
    public ResponseEntity<List<CartItem>> getCartItems(@PathVariable UUID id) {
        return ResponseEntity.ok(customerCartService.getCartItems(id));
    }

    @PostMapping("/{id}/cart")
    public ResponseEntity<CartItem> addToCart(
            @PathVariable UUID id,
            @RequestParam UUID productId,
            @RequestParam(required = false, defaultValue = "1") Integer quantity,
            @RequestParam(required = false, defaultValue = "M") String size,
            @RequestParam(required = false, defaultValue = "White") String color
    ) {
        return ResponseEntity.ok(customerCartService.addToCart(id, productId, quantity, size, color));
    }

    @PutMapping("/cart/items/{itemId}")
    public ResponseEntity<Void> updateCartItemQuantity(@PathVariable UUID itemId, @RequestParam Integer quantity) {
        customerCartService.updateCartItemQuantity(itemId, quantity);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/cart/items/{itemId}")
    public ResponseEntity<Void> removeFromCart(@PathVariable UUID itemId) {
        customerCartService.removeFromCart(itemId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}/cart/clear")
    public ResponseEntity<Void> clearCart(@PathVariable UUID id) {
        customerCartService.clearCart(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/wishlist")
    public ResponseEntity<List<Product>> getWishlist(@PathVariable UUID id) {
        return ResponseEntity.ok(customerCartService.getWishlist(id));
    }

    @PostMapping("/{id}/wishlist")
    public ResponseEntity<Void> addToWishlist(
            @PathVariable UUID id,
            @RequestParam UUID productId
    ) {
        customerCartService.addToWishlist(id, productId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}/wishlist")
    public ResponseEntity<Void> removeFromWishlist(
            @PathVariable UUID id,
            @RequestParam UUID productId
    ) {
        customerCartService.removeFromWishlist(id, productId);
        return ResponseEntity.ok().build();
    }
}
