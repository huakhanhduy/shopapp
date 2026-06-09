package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.auth.AuthResponse;
import com.huakhanhduy.shopapp_backend.dto.auth.LoginRequest;
import com.huakhanhduy.shopapp_backend.dto.auth.RegisterRequest;
import com.huakhanhduy.shopapp_backend.service.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin("*")
public class AuthController {

        private final AuthService authService;

        public AuthController(
                        AuthService authService) {
                this.authService = authService;
        }

        @PostMapping("/register")
        public ResponseEntity<AuthResponse> register(
                        @RequestBody RegisterRequest request) {

                return ResponseEntity.ok(
                                authService.register(request));
        }

        @PostMapping("/login")
        public ResponseEntity<AuthResponse> login(
                        @RequestBody LoginRequest request) {

                return ResponseEntity.ok(
                                authService.login(request));
        }

        @PostMapping("/social-login")
        public ResponseEntity<AuthResponse> socialLogin(
                        @RequestBody java.util.Map<String, String> payload) {
                String email = payload.get("email");
                String provider = payload.get("provider");
                String providerId = payload.get("providerId");
                String firstName = payload.get("firstName");
                String lastName = payload.get("lastName");
                return ResponseEntity.ok(
                                authService.socialLogin(email, provider, providerId, firstName, lastName));
        }
}