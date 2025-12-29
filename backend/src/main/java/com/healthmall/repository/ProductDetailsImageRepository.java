package com.healthmall.repository;

import com.healthmall.entity.ProductDetailsImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductDetailsImageRepository extends JpaRepository<ProductDetailsImage, Integer> {
    List<ProductDetailsImage> findByProductIdOrderBySortOrderAsc(Integer productId);

    void deleteByProductId(Integer productId);
}
