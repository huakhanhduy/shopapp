package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.home.HomeResponse;
import com.huakhanhduy.shopapp_backend.service.HomeService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/home")
@CrossOrigin("*")
public class HomeController {

    private final HomeService homeService;

    public HomeController(
            HomeService homeService
    ) {
        this.homeService = homeService;
    }

    @GetMapping
    public ResponseEntity<HomeResponse> getHome() {

        return ResponseEntity.ok(
                homeService.getHome()
        );
    }
}