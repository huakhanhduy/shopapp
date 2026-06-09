package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.PromoCode;
import java.util.List;

public interface PromoCodeService {
    List<PromoCode> getAvailablePromoCodes();
    PromoCode validatePromoCode(String code);
}
