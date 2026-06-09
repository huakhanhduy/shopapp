package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.dto.payment.PaymentCardRequest;
import com.huakhanhduy.shopapp_backend.entity.PaymentCard;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import java.util.List;
import java.util.UUID;

public interface PaymentCardService {
    List<PaymentCard> getCards(StaffAccount user);
    PaymentCard getCardById(UUID id);
    PaymentCard createCard(PaymentCardRequest request, StaffAccount user);
    PaymentCard updateCard(UUID id, PaymentCardRequest request, StaffAccount user);
    void deleteCard(UUID id, StaffAccount user);
    PaymentCard setDefaultCard(UUID id, StaffAccount user);
}
