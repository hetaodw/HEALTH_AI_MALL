package com.healthmall.repository;

import com.healthmall.entity.ProductReview;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, Integer> {
    
    Page<ProductReview> findByProductIdAndStatus(Integer productId, ProductReview.ReviewStatus status, Pageable pageable);
    
    List<ProductReview> findByProductIdAndStatusOrderByCreatedAtDesc(Integer productId, ProductReview.ReviewStatus status);
    
    long countByProductIdAndStatus(Integer productId, ProductReview.ReviewStatus status);
    
    @Query("SELECT AVG(pr.rating) FROM ProductReview pr WHERE pr.productId = :productId AND pr.status = :status")
    Double findAverageRatingByProductId(@Param("productId") Integer productId, @Param("status") ProductReview.ReviewStatus status);
    
    List<ProductReview> findByUserIdOrderByCreatedAtDesc(Integer userId);
    
    Page<ProductReview> findByUserId(Integer userId, Pageable pageable);
}
