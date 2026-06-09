package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "notifications")
public class Notification extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id")
    private StaffAccount account;

    @Column(length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private Boolean seen = false;

    private Instant receiveTime;

    private LocalDate notificationExpiryDate;

    public Notification() {}

    public StaffAccount getAccount() { return account; }
    public void setAccount(StaffAccount account) { this.account = account; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Boolean getSeen() { return seen; }
    public void setSeen(Boolean seen) { this.seen = seen; }
    public Instant getReceiveTime() { return receiveTime; }
    public void setReceiveTime(Instant receiveTime) { this.receiveTime = receiveTime; }
    public LocalDate getNotificationExpiryDate() { return notificationExpiryDate; }
    public void setNotificationExpiryDate(LocalDate notificationExpiryDate) { this.notificationExpiryDate = notificationExpiryDate; }
}
