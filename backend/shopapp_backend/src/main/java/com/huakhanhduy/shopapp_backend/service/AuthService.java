package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.auth.AuthResponse;
import com.huakhanhduy.shopapp_backend.dto.auth.LoginRequest;
import com.huakhanhduy.shopapp_backend.dto.auth.RegisterRequest;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse socialLogin(String email, String provider, String providerId, String firstName, String lastName);

}