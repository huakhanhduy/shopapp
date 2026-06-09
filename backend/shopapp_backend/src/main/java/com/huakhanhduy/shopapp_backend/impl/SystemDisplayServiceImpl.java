package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.repository.*;
import com.huakhanhduy.shopapp_backend.service.SystemDisplayService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class SystemDisplayServiceImpl implements SystemDisplayService {

    private final SlideshowRepository slideshowRepository;
    private final NotificationRepository notificationRepository;
    private final StaffAccountRepository staffAccountRepository;

    public SystemDisplayServiceImpl(
            SlideshowRepository slideshowRepository,
            NotificationRepository notificationRepository,
            StaffAccountRepository staffAccountRepository
    ) {
        this.slideshowRepository = slideshowRepository;
        this.notificationRepository = notificationRepository;
        this.staffAccountRepository = staffAccountRepository;
    }

    @Override
    public Slideshow createSlideshow(Slideshow slideshow) {
        return slideshowRepository.save(slideshow);
    }

    @Override
    public List<Slideshow> getActiveSlideshows() {
        return slideshowRepository.findByPublishedOrderByDisplayOrderAsc(true);
    }

    @Override
    public Notification createNotification(Notification notification) {
        return notificationRepository.save(notification);
    }

    @Override
    public List<Notification> getNotificationsForAccount(UUID accountId) {
        StaffAccount account = staffAccountRepository.findById(accountId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        return notificationRepository.findByAccountOrderByCreatedAtDesc(account);
    }

    @Override
    public void markNotificationAsSeen(UUID notificationId) {
        Notification notif = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        notif.setSeen(true);
        notificationRepository.save(notif);
    }
}
