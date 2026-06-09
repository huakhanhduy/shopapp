package com.huakhanhduy.shopapp_backend.security;

import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.repository.StaffAccountRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService
        implements UserDetailsService {

    private final StaffAccountRepository staffAccountRepository;

    public CustomUserDetailsService(
            StaffAccountRepository staffAccountRepository
    ) {
        this.staffAccountRepository = staffAccountRepository;
    }

    @Override
    public UserDetails loadUserByUsername(
            String email
    ) throws UsernameNotFoundException {

        StaffAccount user =
                staffAccountRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () -> new UsernameNotFoundException(
                                        "User not found: " + email
                                )
                        );

        return user;
    }
}