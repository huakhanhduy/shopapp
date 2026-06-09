package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.auth.AuthResponse;
import com.huakhanhduy.shopapp_backend.dto.auth.LoginRequest;
import com.huakhanhduy.shopapp_backend.dto.auth.RegisterRequest;
import com.huakhanhduy.shopapp_backend.entity.Role;
import com.huakhanhduy.shopapp_backend.entity.SocialAccount;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.repository.RoleRepository;
import com.huakhanhduy.shopapp_backend.repository.SocialAccountRepository;
import com.huakhanhduy.shopapp_backend.repository.StaffAccountRepository;
import com.huakhanhduy.shopapp_backend.security.jwt.JwtService;
import com.huakhanhduy.shopapp_backend.service.AuthService;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthServiceImpl implements AuthService {

    private final StaffAccountRepository staffAccountRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final SocialAccountRepository socialAccountRepository;
    private final com.huakhanhduy.shopapp_backend.repository.CustomerRepository customerRepository;

    public AuthServiceImpl(
            StaffAccountRepository staffAccountRepository,
            RoleRepository roleRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            SocialAccountRepository socialAccountRepository,
            com.huakhanhduy.shopapp_backend.repository.CustomerRepository customerRepository
    ) {
        this.staffAccountRepository = staffAccountRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.socialAccountRepository = socialAccountRepository;
        this.customerRepository = customerRepository;
    }

    @Override
    public AuthResponse register(RegisterRequest request) {

        if (staffAccountRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        Role userRole = roleRepository
                .findByRoleName("ROLE_USER")
                .orElseThrow(() ->
                        new RuntimeException("ROLE_USER not found"));

        StaffAccount account = new StaffAccount();

        account.setFirstName(request.getFirstName());
        account.setLastName(request.getLastName());
        account.setPhoneNumber(request.getPhoneNumber());
        account.setEmail(request.getEmail());

        account.setPasswordHash(
                passwordEncoder.encode(
                        request.getPassword()
                )
        );

        account.setRole(userRole);
        account.setActive(true);

        staffAccountRepository.save(account);

        com.huakhanhduy.shopapp_backend.entity.Customer customer = new com.huakhanhduy.shopapp_backend.entity.Customer();
        customer.setFirstName(request.getFirstName());
        customer.setLastName(request.getLastName());
        customer.setEmail(request.getEmail());
        customer.setPasswordHash(account.getPasswordHash());
        customer.setActive(true);
        customerRepository.save(customer);

        String token =
                jwtService.generateToken(account);

        return new AuthResponse(token);
    }

    @Override
    public AuthResponse login(LoginRequest request) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        StaffAccount account =
                staffAccountRepository
                        .findByEmail(request.getEmail())
                        .orElseThrow();

        String token =
                jwtService.generateToken(account);

        return new AuthResponse(token);
    }

    @Override
    @org.springframework.transaction.annotation.Transactional
    public AuthResponse socialLogin(String email, String provider, String providerId, String firstName, String lastName) {
        java.util.Optional<StaffAccount> existing = staffAccountRepository.findByEmail(email);
        StaffAccount account;
        if (existing.isPresent()) {
            account = existing.get();
        } else {
            Role userRole = roleRepository.findByRoleName("ROLE_USER")
                    .orElseThrow(() -> new RuntimeException("ROLE_USER not found"));

            StaffAccount newAccount = new StaffAccount();
            newAccount.setEmail(email);
            newAccount.setFirstName(firstName != null && !firstName.isEmpty() ? firstName : "User");
            newAccount.setLastName(lastName != null && !lastName.isEmpty() ? lastName : "Social");
            newAccount.setPasswordHash(passwordEncoder.encode(java.util.UUID.randomUUID().toString()));
            newAccount.setRole(userRole);
            newAccount.setActive(true);
            account = staffAccountRepository.save(newAccount);
        }

        if (customerRepository.findByEmail(email).isEmpty()) {
            com.huakhanhduy.shopapp_backend.entity.Customer customer = new com.huakhanhduy.shopapp_backend.entity.Customer();
            customer.setEmail(email);
            customer.setFirstName(firstName != null && !firstName.isEmpty() ? firstName : "User");
            customer.setLastName(lastName != null && !lastName.isEmpty() ? lastName : "Social");
            customer.setPasswordHash(account.getPasswordHash());
            customer.setActive(true);
            customerRepository.save(customer);
        }

        if (socialAccountRepository.findByProviderAndProviderId(provider, providerId).isEmpty()) {
            SocialAccount socialAccount = new SocialAccount();
            socialAccount.setProvider(provider);
            socialAccount.setProviderId(providerId);
            socialAccount.setUser(account);
            socialAccountRepository.save(socialAccount);
        }

        String token = jwtService.generateToken(account);
        return new AuthResponse(token);
    }
}