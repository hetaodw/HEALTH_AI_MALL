package com.healthmall.repository;

import com.healthmall.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Integer> {

    @Query("SELECT p FROM Product p WHERE " +
           "(:keyword IS NULL OR p.title LIKE %:keyword% OR p.description LIKE %:keyword%) AND " +
           "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.price <= :maxPrice) AND " +
           "p.status <> 'OFF_SALE'")
    Page<Product> searchProducts(@Param("keyword") String keyword,
                                  @Param("minPrice") BigDecimal minPrice,
                                  @Param("maxPrice") BigDecimal maxPrice,
                                  Pageable pageable);

    @Query("SELECT p FROM Product p WHERE " +
           "(:category IS NULL OR p.category = :category) AND " +
           "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.price <= :maxPrice) AND " +
           "p.status <> 'OFF_SALE'")
    Page<Product> findProducts(@Param("category") String category,
                               @Param("minPrice") BigDecimal minPrice,
                               @Param("maxPrice") BigDecimal maxPrice,
                               Pageable pageable);

    @Query("SELECT p FROM Product p JOIN HotProduct hp ON p.id = hp.productId WHERE p.status <> 'OFF_SALE' ORDER BY hp.hotScore DESC")
    List<Product> findHotProducts(Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.category = :category AND p.status <> 'OFF_SALE'")
    Page<Product> findByCategory(@Param("category") String category, Pageable pageable);

    Page<Product> findByMerchantId(Integer merchantId, Pageable pageable);

    Page<Product> findByMerchantIdAndStatus(Integer merchantId, com.healthmall.entity.Product.ProductStatus status, Pageable pageable);

    Page<Product> findByMerchantIdAndCategory(Integer merchantId, String category, Pageable pageable);
}
