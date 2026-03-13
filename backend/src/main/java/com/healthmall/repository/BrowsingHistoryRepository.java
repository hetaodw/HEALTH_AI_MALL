package com.healthmall.repository;

import com.healthmall.entity.BrowsingHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Repository
public interface BrowsingHistoryRepository extends JpaRepository<BrowsingHistory, Integer> {

    Page<BrowsingHistory> findByUserIdOrderByViewedAtDesc(Integer userId, Pageable pageable);

    @Transactional
    @Modifying
    void deleteByUserId(Integer userId);

    @Transactional
    @Modifying
    void deleteByUserIdAndProductId(Integer userId, Integer productId);

    @Query("SELECT COUNT(bh) FROM BrowsingHistory bh WHERE bh.userId = :userId")
    Long countByUserId(@Param("userId") Integer userId);

    Optional<BrowsingHistory> findByUserIdAndProductId(Integer userId, Integer productId);

    @Transactional
    @Modifying
    @Query("DELETE FROM BrowsingHistory bh WHERE bh.userId = :userId AND bh.id IN " +
           "(SELECT bh2.id FROM BrowsingHistory bh2 WHERE bh2.userId = :userId " +
           "ORDER BY bh2.viewedAt ASC LIMIT 1 OFFSET :offset)")
    void deleteOldestByUserId(@Param("userId") Integer userId, @Param("offset") int offset);
}
