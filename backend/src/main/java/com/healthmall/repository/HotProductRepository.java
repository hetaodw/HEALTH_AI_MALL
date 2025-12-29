package com.healthmall.repository;

import com.healthmall.entity.HotProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface HotProductRepository extends JpaRepository<HotProduct, Integer> {
    Optional<HotProduct> findByProductId(Integer productId);
}
