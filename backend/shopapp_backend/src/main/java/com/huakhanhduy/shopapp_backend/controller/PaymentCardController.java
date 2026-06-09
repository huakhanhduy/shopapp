package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.dto.payment.PaymentCardRequest;
import com.huakhanhduy.shopapp_backend.entity.PaymentCard;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.service.PaymentCardService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/cards")
@CrossOrigin("*")
public class PaymentCardController {

    private final PaymentCardService paymentCardService;

    public PaymentCardController(PaymentCardService paymentCardService) {
        this.paymentCardService = paymentCardService;
    }

    @GetMapping
    public ResponseEntity<List<PaymentCard>> getCards(
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(paymentCardService.getCards(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentCard> getCardById(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(paymentCardService.getCardById(id));
    }

    @PostMapping
    public ResponseEntity<PaymentCard> createCard(
            @RequestBody PaymentCardRequest request,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(paymentCardService.createCard(request, user));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PaymentCard> updateCard(
            @PathVariable UUID id,
            @RequestBody PaymentCardRequest request,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(paymentCardService.updateCard(id, request, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteCard(
            @PathVariable UUID id,
            @AuthenticationPrincipal StaffAccount user
    ) {
        paymentCardService.deleteCard(id, user);
        return ResponseEntity.ok("Xóa thẻ thành công");
    }

    @PutMapping("/{id}/default")
    public ResponseEntity<PaymentCard> setDefaultCard(
            @PathVariable UUID id,
            @AuthenticationPrincipal StaffAccount user
    ) {
        return ResponseEntity.ok(paymentCardService.setDefaultCard(id, user));
    }
}
