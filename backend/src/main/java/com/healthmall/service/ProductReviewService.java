package com.healthmall.service;

import com.healthmall.dto.ProductReviewResponse;
import com.healthmall.entity.Product;
import com.healthmall.entity.ProductReview;
import com.healthmall.entity.User;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductRepository;
import com.healthmall.repository.ProductReviewRepository;
import com.healthmall.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductReviewService {

    @Autowired
    private ProductReviewRepository productReviewRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private UserRepository userRepository;

    public List<ProductReviewResponse> getProductReviews(Integer productId, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<ProductReview> reviewPage = productReviewRepository.findByProductIdAndStatus(
                productId, 
                ProductReview.ReviewStatus.APPROVED, 
                pageable
        );

        return reviewPage.getContent().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public ProductReviewResponse getProductReview(Integer reviewId) {
        ProductReview review = productReviewRepository.findById(reviewId)
                .orElseThrow(() -> new BusinessException(404, "评价不存在"));
        return convertToResponse(review);
    }

    @Transactional
    public ProductReviewResponse createReview(Integer productId, Integer userId, Integer rating, 
                                               String title, String content, Boolean isAnonymous) {
        if (rating < 1 || rating > 5) {
            throw new BusinessException(400, "评分必须在 1-5 之间");
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(404, "用户不存在"));

        ProductReview review = new ProductReview();
        review.setProductId(productId);
        review.setUserId(userId);
        review.setRating(rating);
        review.setTitle(title);
        review.setContent(content);
        review.setIsAnonymous(isAnonymous != null ? isAnonymous : false);
        review.setStatus(ProductReview.ReviewStatus.APPROVED);

        ProductReview savedReview = productReviewRepository.save(review);

        updateProductRating(productId);

        return convertToResponse(savedReview);
    }

    @Transactional
    public void deleteReview(Integer reviewId, Integer userId) {
        ProductReview review = productReviewRepository.findById(reviewId)
                .orElseThrow(() -> new BusinessException(404, "评价不存在"));

        if (!review.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权删除此评价");
        }

        Integer productId = review.getProductId();
        productReviewRepository.delete(review);

        updateProductRating(productId);
    }

    public Double getProductAverageRating(Integer productId) {
        return productReviewRepository.findAverageRatingByProductId(productId, ProductReview.ReviewStatus.APPROVED);
    }

    public Long getProductReviewCount(Integer productId) {
        return productReviewRepository.countByProductIdAndStatus(productId, ProductReview.ReviewStatus.APPROVED);
    }

    @Transactional
    public void updateProductRating(Integer productId) {
        Double averageRating = productReviewRepository.findAverageRatingByProductId(productId, ProductReview.ReviewStatus.APPROVED);
        Long reviewCount = productReviewRepository.countByProductIdAndStatus(productId, ProductReview.ReviewStatus.APPROVED);

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        product.setAverageRating(averageRating != null ? averageRating : 0.0);
        product.setReviewCount(reviewCount != null ? reviewCount.intValue() : 0);
        productRepository.save(product);
    }

    private ProductReviewResponse convertToResponse(ProductReview review) {
        ProductReviewResponse response = new ProductReviewResponse();
        response.setId(review.getId());
        response.setProductId(review.getProductId());
        response.setUserId(review.getUserId());
        response.setRating(review.getRating());
        response.setTitle(review.getTitle());
        response.setContent(review.getContent());
        response.setIsAnonymous(review.getIsAnonymous());
        response.setStatus(review.getStatus().name());
        response.setCreatedAt(review.getCreatedAt());

        if (!review.getIsAnonymous()) {
            User user = userRepository.findById(review.getUserId())
                    .orElse(null);
            if (user != null) {
                response.setUsername(user.getUsername());
                response.setUserAvatar(user.getAvatarUrl());
            }
        } else {
            response.setUsername("匿名用户");
            response.setUserAvatar(null);
        }

        return response;
    }
}
