package com.healthmall.service;

import com.healthmall.dto.PageResponse;
import com.healthmall.dto.ProductDetailResponse;
import com.healthmall.dto.ProductListItem;
import com.healthmall.entity.Product;
import com.healthmall.entity.ProductDetailsImage;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductDetailsImageRepository;
import com.healthmall.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ProductDetailsImageRepository productDetailsImageRepository;

    public PageResponse<ProductListItem> getProductList(Integer page, Integer size, Boolean isHot,
                                                         String category, BigDecimal minPrice,
                                                         BigDecimal maxPrice, String sortBy,
                                                         String sortOrder) {
        Sort sort = Sort.by("createdAt").descending();

        if (sortBy != null && !sortBy.isEmpty()) {
            Sort.Direction direction = "desc".equalsIgnoreCase(sortOrder) ? Sort.Direction.DESC : Sort.Direction.ASC;
            sort = Sort.by(direction, sortBy);
        }

        Pageable pageable = PageRequest.of(page - 1, size, sort);
        Page<Product> productPage;

        if (isHot != null && isHot) {
            List<Product> hotProducts = productRepository.findHotProducts(pageable);
            productPage = new org.springframework.data.domain.PageImpl<>(
                    hotProducts,
                    pageable,
                    hotProducts.size()
            );
        } else {
            productPage = productRepository.findProducts(category, minPrice, maxPrice, pageable);
        }

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }

    public PageResponse<ProductListItem> searchProducts(String keyword, BigDecimal minPrice,
                                                          BigDecimal maxPrice, String sortBy,
                                                          Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Product> productPage = productRepository.searchProducts(keyword, minPrice, maxPrice, pageable);

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }

    public List<ProductListItem> getHotProducts(Integer limit) {
        Pageable pageable = PageRequest.of(0, limit);
        List<Product> hotProducts = productRepository.findHotProducts(pageable);
        return hotProducts.stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());
    }

    public ProductDetailResponse getProductDetail(Integer id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        List<ProductDetailsImage> detailImages = productDetailsImageRepository
                .findByProductIdOrderBySortOrderAsc(id);

        List<String> imageUrls = detailImages.stream()
                .map(ProductDetailsImage::getImageUrl)
                .collect(Collectors.toList());

        return new ProductDetailResponse(product, imageUrls);
    }

    public Integer createProduct(String name, String category, BigDecimal price,
                                 Integer stock, String description, String coverUrl, String features) {
        Product product = new Product();
        product.setTitle(name);
        product.setCategory(category);
        product.setPrice(price);
        product.setStock(stock);
        product.setDescription(description);
        product.setCoverUrl(coverUrl != null ? coverUrl : "https://via.placeholder.com/300");
        product.setFeatures(features);

        Product savedProduct = productRepository.save(product);
        return savedProduct.getId();
    }

    public PageResponse<ProductListItem> getProductsByCategory(String category, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Product> productPage = productRepository.findByCategory(category, pageable);

        List<ProductListItem> items = productPage.getContent().stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, productPage.getTotalElements());
    }
}
