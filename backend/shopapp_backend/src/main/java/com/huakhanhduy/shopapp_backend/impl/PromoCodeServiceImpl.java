package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.PromoCode;
import com.huakhanhduy.shopapp_backend.repository.PromoCodeRepository;
import com.huakhanhduy.shopapp_backend.service.PromoCodeService;
import org.springframework.stereotype.Service;
import java.time.Instant;
import java.util.List;

@Service
public class PromoCodeServiceImpl implements PromoCodeService {

    private final PromoCodeRepository promoCodeRepository;

    public PromoCodeServiceImpl(PromoCodeRepository promoCodeRepository) {
        this.promoCodeRepository = promoCodeRepository;
    }

    @Override
    public List<PromoCode> getAvailablePromoCodes() {
        return promoCodeRepository.findAll().stream()
                .filter(pc -> Boolean.TRUE.equals(pc.getActive()) && (pc.getExpiryDate() == null || pc.getExpiryDate().isAfter(Instant.now())))
                .toList();
    }

    @Override
    public PromoCode validatePromoCode(String code) {
        PromoCode promo = promoCodeRepository.findByCodeIgnoreCaseAndActiveTrue(code)
                .orElseThrow(() -> new RuntimeException("Mã giảm giá không tồn tại hoặc đã hết hạn"));

        if (promo.getExpiryDate() != null && promo.getExpiryDate().isBefore(Instant.now())) {
            throw new RuntimeException("Mã giảm giá đã hết hạn sử dụng");
        }

        return promo;
    }
}
