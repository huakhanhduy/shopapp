package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.dto.payment.PaymentCardRequest;
import com.huakhanhduy.shopapp_backend.entity.PaymentCard;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import com.huakhanhduy.shopapp_backend.repository.PaymentCardRepository;
import com.huakhanhduy.shopapp_backend.service.PaymentCardService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;

@Service
public class PaymentCardServiceImpl implements PaymentCardService {

    private final PaymentCardRepository paymentCardRepository;

    public PaymentCardServiceImpl(PaymentCardRepository paymentCardRepository) {
        this.paymentCardRepository = paymentCardRepository;
    }

    @Override
    public List<PaymentCard> getCards(StaffAccount user) {
        return paymentCardRepository.findByUserOrderByIsDefaultDesc(user);
    }

    @Override
    public PaymentCard getCardById(UUID id) {
        return paymentCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Card not found"));
    }

    @Override
    @Transactional
    public PaymentCard createCard(PaymentCardRequest request, StaffAccount user) {
        PaymentCard card = new PaymentCard();
        card.setCardHolderName(request.getCardHolderName());
        card.setCardNumber(request.getCardNumber());
        card.setExpiryDate(request.getExpiryDate());
        card.setCardType(request.getCardType());
        card.setUser(user);

        if (Boolean.TRUE.equals(request.getIsDefault())) {
            clearOtherDefaults(user);
            card.setIsDefault(true);
        } else {
            List<PaymentCard> existing = paymentCardRepository.findByUser(user);
            card.setIsDefault(existing.isEmpty());
        }

        return paymentCardRepository.save(card);
    }

    @Override
    @Transactional
    public PaymentCard updateCard(UUID id, PaymentCardRequest request, StaffAccount user) {
        PaymentCard card = paymentCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (!card.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        card.setCardHolderName(request.getCardHolderName());
        card.setCardNumber(request.getCardNumber());
        card.setExpiryDate(request.getExpiryDate());
        card.setCardType(request.getCardType());

        if (Boolean.TRUE.equals(request.getIsDefault()) && !Boolean.TRUE.equals(card.getIsDefault())) {
            clearOtherDefaults(user);
            card.setIsDefault(true);
        }

        return paymentCardRepository.save(card);
    }

    @Override
    @Transactional
    public void deleteCard(UUID id, StaffAccount user) {
        PaymentCard card = paymentCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (!card.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        paymentCardRepository.delete(card);

        if (Boolean.TRUE.equals(card.getIsDefault())) {
            List<PaymentCard> existing = paymentCardRepository.findByUser(user);
            if (!existing.isEmpty()) {
                PaymentCard newDefault = existing.get(0);
                newDefault.setIsDefault(true);
                paymentCardRepository.save(newDefault);
            }
        }
    }

    @Override
    @Transactional
    public PaymentCard setDefaultCard(UUID id, StaffAccount user) {
        PaymentCard card = paymentCardRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Card not found"));

        if (!card.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        clearOtherDefaults(user);
        card.setIsDefault(true);
        return paymentCardRepository.save(card);
    }

    private void clearOtherDefaults(StaffAccount user) {
        List<PaymentCard> cards = paymentCardRepository.findByUser(user);
        for (PaymentCard card : cards) {
            if (Boolean.TRUE.equals(card.getIsDefault())) {
                card.setIsDefault(false);
                paymentCardRepository.save(card);
            }
        }
    }
}
