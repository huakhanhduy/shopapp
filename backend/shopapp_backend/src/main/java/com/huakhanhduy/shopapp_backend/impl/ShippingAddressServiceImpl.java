package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.address.ShippingAddressRequest;
import com.huakhanhduy.shopapp_backend.entity.ShippingAddress;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.repository.ShippingAddressRepository;
import com.huakhanhduy.shopapp_backend.service.ShippingAddressService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;

@Service
public class ShippingAddressServiceImpl implements ShippingAddressService {

    private final ShippingAddressRepository shippingAddressRepository;

    public ShippingAddressServiceImpl(ShippingAddressRepository shippingAddressRepository) {
        this.shippingAddressRepository = shippingAddressRepository;
    }

    @Override
    public List<ShippingAddress> getAddresses(StaffAccount user) {
        return shippingAddressRepository.findByUserOrderByIsDefaultDesc(user);
    }

    @Override
    public ShippingAddress getAddressById(UUID id) {
        return shippingAddressRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Address not found"));
    }

    @Override
    @Transactional
    public ShippingAddress createAddress(ShippingAddressRequest request, StaffAccount user) {
        ShippingAddress address = new ShippingAddress();
        address.setFullName(request.getFullName());
        address.setPhoneNumber(request.getPhoneNumber());
        address.setStreetAddress(request.getStreetAddress());
        address.setCity(request.getCity());
        address.setState(request.getState());
        address.setZipCode(request.getZipCode());
        address.setCountry(request.getCountry());
        address.setUser(user);
        
        if (Boolean.TRUE.equals(request.getIsDefault())) {
            clearOtherDefaults(user);
            address.setIsDefault(true);
        } else {
            // If it is the first address, make it default
            List<ShippingAddress> existing = shippingAddressRepository.findByUser(user);
            address.setIsDefault(existing.isEmpty());
        }

        return shippingAddressRepository.save(address);
    }

    @Override
    @Transactional
    public ShippingAddress updateAddress(UUID id, ShippingAddressRequest request, StaffAccount user) {
        ShippingAddress address = shippingAddressRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        
        if (!address.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        address.setFullName(request.getFullName());
        address.setPhoneNumber(request.getPhoneNumber());
        address.setStreetAddress(request.getStreetAddress());
        address.setCity(request.getCity());
        address.setState(request.getState());
        address.setZipCode(request.getZipCode());
        address.setCountry(request.getCountry());

        if (Boolean.TRUE.equals(request.getIsDefault()) && !Boolean.TRUE.equals(address.getIsDefault())) {
            clearOtherDefaults(user);
            address.setIsDefault(true);
        }

        return shippingAddressRepository.save(address);
    }

    @Override
    @Transactional
    public void deleteAddress(UUID id, StaffAccount user) {
        ShippingAddress address = shippingAddressRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Address not found"));

        if (!address.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        shippingAddressRepository.delete(address);
        
        // If deleted default address, make another one default
        if (Boolean.TRUE.equals(address.getIsDefault())) {
            List<ShippingAddress> existing = shippingAddressRepository.findByUser(user);
            if (!existing.isEmpty()) {
                ShippingAddress newDefault = existing.get(0);
                newDefault.setIsDefault(true);
                shippingAddressRepository.save(newDefault);
            }
        }
    }

    @Override
    @Transactional
    public ShippingAddress setDefaultAddress(UUID id, StaffAccount user) {
        ShippingAddress address = shippingAddressRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Address not found"));

        if (!address.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        clearOtherDefaults(user);
        address.setIsDefault(true);
        return shippingAddressRepository.save(address);
    }

    private void clearOtherDefaults(StaffAccount user) {
        List<ShippingAddress> defaults = shippingAddressRepository.findByUser(user);
        for (ShippingAddress ad : defaults) {
            if (Boolean.TRUE.equals(ad.getIsDefault())) {
                ad.setIsDefault(false);
                shippingAddressRepository.save(ad);
            }
        }
    }
}
