package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.PromoCode;
import com.huakhanhduy.shopapp_backend.service.PromoCodeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/promocodes")
@CrossOrigin("*")
public class PromoCodeController {

    private final PromoCodeService promoCodeService;

    public PromoCodeController(PromoCodeService promoCodeService) {
        this.promoCodeService = promoCodeService;
    }

    @GetMapping
    public ResponseEntity<List<PromoCode>> getAvailablePromoCodes() {
        return ResponseEntity.ok(promoCodeService.getAvailablePromoCodes());
    }

    @GetMapping("/validate")
    public ResponseEntity<PromoCode> validatePromoCode(
            @RequestParam String code
    ) {
        try {
            PromoCode promo = promoCodeService.validatePromoCode(code);
            return ResponseEntity.ok(promo);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
}
