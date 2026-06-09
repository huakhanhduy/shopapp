package com.huakhanhduy.shopapp_backend.repository;

import com.huakhanhduy.shopapp_backend.entity.PaymentCard;
import com.huakhanhduy.shopapp_backend.entity.StaffAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface PaymentCardRepository extends JpaRepository<PaymentCard, UUID> {
    List<PaymentCard> findByUser(StaffAccount user);
    List<PaymentCard> findByUserOrderByIsDefaultDesc(StaffAccount user);
}
