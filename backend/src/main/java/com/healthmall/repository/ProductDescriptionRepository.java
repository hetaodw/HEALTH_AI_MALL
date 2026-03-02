package com.healthmall.repository;

import com.healthmall.entity.ProductDescription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProductDescriptionRepository extends JpaRepository<ProductDescription, Integer> {
    Optional<ProductDescription> findByProductId(Integer productId);
    
    void deleteByProductId(Integer productId);
}
