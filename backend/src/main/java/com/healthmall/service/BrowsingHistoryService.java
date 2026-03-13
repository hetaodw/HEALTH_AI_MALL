package com.healthmall.service;

import com.healthmall.dto.BrowsingHistoryItem;
import com.healthmall.dto.PageResponse;
import com.healthmall.entity.BrowsingHistory;
import com.healthmall.entity.Product;
import com.healthmall.repository.BrowsingHistoryRepository;
import com.healthmall.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class BrowsingHistoryService {

    @Autowired
    private BrowsingHistoryRepository browsingHistoryRepository;

    @Autowired
    private ProductRepository productRepository;

    private static final int MAX_HISTORY_SIZE = 100;

    @Transactional
    public void addBrowsingHistory(Integer userId, Integer productId) {
        BrowsingHistory existing = browsingHistoryRepository
            .findByUserIdAndProductId(userId, productId)
            .orElse(null);

        if (existing != null) {
            existing.setViewedAt(java.time.LocalDateTime.now());
            browsingHistoryRepository.save(existing);
            return;
        }

        Long count = browsingHistoryRepository.countByUserId(userId);

        if (count >= MAX_HISTORY_SIZE) {
            browsingHistoryRepository.deleteOldestByUserId(userId, 1);
        }

        BrowsingHistory history = new BrowsingHistory();
        history.setUserId(userId);
        history.setProductId(productId);
        browsingHistoryRepository.save(history);
    }

    public PageResponse<BrowsingHistoryItem> getBrowsingHistory(Integer userId, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("viewedAt").descending());
        Page<BrowsingHistory> historyPage = browsingHistoryRepository.findByUserIdOrderByViewedAtDesc(userId, pageable);

        Set<Integer> productIds = historyPage.getContent().stream()
            .map(BrowsingHistory::getProductId)
            .collect(Collectors.toSet());

        Map<Integer, Product> productMap = productRepository.findAllById(productIds)
            .stream()
            .collect(Collectors.toMap(Product::getId, p -> p));

        List<BrowsingHistoryItem> items = historyPage.getContent().stream()
            .map(bh -> new BrowsingHistoryItem(bh, productMap.get(bh.getProductId())))
            .filter(item -> item.getProductTitle() != null)
            .collect(Collectors.toList());

        return new PageResponse<>(items, historyPage.getTotalElements());
    }

    @Transactional
    public void deleteBrowsingHistory(Integer userId, Integer productId) {
        browsingHistoryRepository.deleteByUserIdAndProductId(userId, productId);
    }

    @Transactional
    public void clearBrowsingHistory(Integer userId) {
        browsingHistoryRepository.deleteByUserId(userId);
    }
}
