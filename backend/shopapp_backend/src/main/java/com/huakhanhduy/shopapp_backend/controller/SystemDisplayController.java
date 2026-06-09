package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.*;
import com.huakhanhduy.shopapp_backend.service.SystemDisplayService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/display")
public class SystemDisplayController {

    private final SystemDisplayService systemDisplayService;

    public SystemDisplayController(SystemDisplayService systemDisplayService) {
        this.systemDisplayService = systemDisplayService;
    }

    @PostMapping("/slideshows")
    public ResponseEntity<Slideshow> createSlideshow(@RequestBody Slideshow slideshow) {
        return ResponseEntity.ok(systemDisplayService.createSlideshow(slideshow));
    }

    @GetMapping("/slideshows")
    public ResponseEntity<List<Slideshow>> getActiveSlideshows() {
        return ResponseEntity.ok(systemDisplayService.getActiveSlideshows());
    }

    @PostMapping("/notifications")
    public ResponseEntity<Notification> createNotification(@RequestBody Notification notification) {
        return ResponseEntity.ok(systemDisplayService.createNotification(notification));
    }

    @GetMapping("/notifications/accounts/{accountId}")
    public ResponseEntity<List<Notification>> getNotificationsForAccount(@PathVariable UUID accountId) {
        return ResponseEntity.ok(systemDisplayService.getNotificationsForAccount(accountId));
    }

    @PutMapping("/notifications/{notificationId}/seen")
    public ResponseEntity<Void> markNotificationAsSeen(@PathVariable UUID notificationId) {
        systemDisplayService.markNotificationAsSeen(notificationId);
        return ResponseEntity.ok().build();
    }
}
