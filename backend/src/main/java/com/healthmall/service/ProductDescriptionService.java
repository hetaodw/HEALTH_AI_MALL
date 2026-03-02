package com.healthmall.service;

import com.healthmall.dto.ProductDescriptionResponse;
import com.healthmall.entity.ProductDescription;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductDescriptionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class ProductDescriptionService {

    @Autowired
    private ProductDescriptionRepository productDescriptionRepository;

    public ProductDescriptionResponse getProductDescriptionByProductId(Integer productId) {
        Optional<ProductDescription> description = productDescriptionRepository.findByProductId(productId);
        return description.map(this::convertToResponse)
                .orElse(null);
    }

    @Transactional
    public ProductDescriptionResponse createOrUpdateProductDescription(Integer productId, String content) {
        Optional<ProductDescription> existing = productDescriptionRepository.findByProductId(productId);
        
        ProductDescription description;
        if (existing.isPresent()) {
            description = existing.get();
            description.setContent(content);
        } else {
            description = new ProductDescription();
            description.setProductId(productId);
            description.setContent(content);
        }
        
        ProductDescription saved = productDescriptionRepository.save(description);
        return convertToResponse(saved);
    }

    @Transactional
    public void deleteProductDescription(Integer productId) {
        productDescriptionRepository.deleteByProductId(productId);
    }

    private ProductDescriptionResponse convertToResponse(ProductDescription description) {
        return new ProductDescriptionResponse(
                description.getId(),
                description.getProductId(),
                description.getContent(),
                description.getCreatedAt(),
                description.getUpdatedAt()
        );
    }
}
