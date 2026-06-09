package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.repository.StaffAccountRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin("*")
public class UserController {

    private final StaffAccountRepository staffAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public UserController(StaffAccountRepository staffAccountRepository, PasswordEncoder passwordEncoder) {
        this.staffAccountRepository = staffAccountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/me")
    public ResponseEntity<StaffAccount> me(@AuthenticationPrincipal StaffAccount user) {
        return ResponseEntity.ok(user);
    }

    @PutMapping("/me")
    public ResponseEntity<StaffAccount> updateProfile(
            @RequestBody Map<String, String> payload,
            @AuthenticationPrincipal StaffAccount user
    ) {
        user.setFirstName(payload.get("firstName"));
        user.setLastName(payload.get("lastName"));
        user.setPhoneNumber(payload.get("phoneNumber"));
        return ResponseEntity.ok(staffAccountRepository.save(user));
    }

    @PostMapping("/change-password")
    public ResponseEntity<String> changePassword(
            @RequestBody Map<String, String> payload,
            @AuthenticationPrincipal StaffAccount user
    ) {
        String oldPassword = payload.get("oldPassword");
        String newPassword = payload.get("newPassword");

        if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
            return ResponseEntity.badRequest().body("Mật khẩu cũ không chính xác");
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        staffAccountRepository.save(user);
        return ResponseEntity.ok("Đổi mật khẩu thành công");
    }
}