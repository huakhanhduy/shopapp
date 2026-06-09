package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "social_accounts")
public class SocialAccount extends BaseEntity {

    @Column(nullable = false)
    private String provider;

    @Column(nullable = false)
    private String providerId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private StaffAccount user;

    public SocialAccount() {
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public StaffAccount getUser() {
        return user;
    }

    public void setUser(StaffAccount user) {
        this.user = user;
    }
}
