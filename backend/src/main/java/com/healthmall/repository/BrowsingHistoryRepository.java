package com.healthmall.repository;

import com.healthmall.entity.BrowsingHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface BrowsingHistoryRepository extends JpaRepository<BrowsingHistory, Integer> {

    Page<BrowsingHistory> findByUserIdOrderByViewedAtDesc(Integer userId, Pageable pageable);

    void deleteByUserId(Integer userId);

    void deleteByUserIdAndProductId(Integer userId, Integer productId);

    @Query("SELECT COUNT(bh) FROM BrowsingHistory bh WHERE bh.userId = :userId")
    Long countByUserId(@Param("userId") Integer userId);
}
