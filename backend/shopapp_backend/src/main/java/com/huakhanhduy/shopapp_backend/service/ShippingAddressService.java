package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.address.ShippingAddressRequest;
import com.huakhanhduy.shopapp_backend.entity.ShippingAddress;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import java.util.List;
import java.util.UUID;

public interface ShippingAddressService {
    List<ShippingAddress> getAddresses(StaffAccount user);
    ShippingAddress getAddressById(UUID id);
    ShippingAddress createAddress(ShippingAddressRequest request, StaffAccount user);
    ShippingAddress updateAddress(UUID id, ShippingAddressRequest request, StaffAccount user);
    void deleteAddress(UUID id, StaffAccount user);
    ShippingAddress setDefaultAddress(UUID id, StaffAccount user);
}
