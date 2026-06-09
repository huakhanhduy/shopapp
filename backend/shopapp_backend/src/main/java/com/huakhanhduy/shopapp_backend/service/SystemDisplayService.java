package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.*;
import java.util.List;
import java.util.UUID;

public interface SystemDisplayService {
    // Slideshows
    Slideshow createSlideshow(Slideshow slideshow);
    List<Slideshow> getActiveSlideshows();

    // Notifications
    Notification createNotification(Notification notification);
    List<Notification> getNotificationsForAccount(UUID accountId);
    void markNotificationAsSeen(UUID notificationId);
}
