package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.address.ShippingAddressRequest;
import com.huakhanhduy.shopapp_backend.entity.ShippingAddress;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.service.ShippingAddressService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/addresses")
@CrossOrigin("*")
public class ShippingAddressController {

    private final ShippingAddressService shippingAddressService;

    public ShippingAddressController(ShippingAddressService shippingAddressService) {
        this.shippingAddressService = shippingAddressService;
    }

    @GetMapping
    public ResponseEntity<List<ShippingAddress>> getAddresses(
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(shippingAddressService.getAddresses(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShippingAddress> getAddressById(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(shippingAddressService.getAddressById(id));
    }

    @PostMapping
    public ResponseEntity<ShippingAddress> createAddress(
            @RequestBody ShippingAddressRequest request,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(shippingAddressService.createAddress(request, user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShippingAddress> updateAddress(
            @PathVariable UUID id,
            @RequestBody ShippingAddressRequest request,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(shippingAddressService.updateAddress(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteAddress(
            @PathVariable UUID id,
            @AuthenticationPrincipal StaffAccount user
    ) {
        shippingAddressService.deleteAddress(id, user);
        return ResponseEntity.ok("Xóa địa chỉ thành công");
    }

    @PutMapping("/{id}/default")
    public ResponseEntity<ShippingAddress> setDefaultAddress(
            @PathVariable UUID id,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(shippingAddressService.setDefaultAddress(id, user));
    }
}
