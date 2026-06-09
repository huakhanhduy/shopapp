package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "user_tokens")
public class UserToken extends BaseEntity {

    @Column(nullable = false, unique = true)
    private String token;

    @Column(nullable = false)
    private Instant expiryDate;

    private boolean revoked;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private StaffAccount user;

    public UserToken() {
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Instant getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Instant expiryDate) {
        this.expiryDate = expiryDate;
    }

    public boolean isRevoked() {
        return revoked;
    }

    public void setRevoked(boolean revoked) {
        this.revoked = revoked;
    }

    public StaffAccount getUser() {
        return user;
    }

    public void setUser(StaffAccount user) {
        this.user = user;
    }
}
