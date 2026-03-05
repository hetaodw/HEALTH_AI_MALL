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

import java.util.List;
import java.util.stream.Collectors;

@Service
public class BrowsingHistoryService {

    @Autowired
    private BrowsingHistoryRepository browsingHistoryRepository;

    @Autowired
    private ProductRepository productRepository;

    private static final int MAX_HISTORY_SIZE = 100;

    public void addBrowsingHistory(Integer userId, Integer productId) {
        Long count = browsingHistoryRepository.countByUserId(userId);

        if (count >= MAX_HISTORY_SIZE) {
            Pageable pageable = PageRequest.of(0, 1, Sort.by("viewed_at").ascending());
            Page<BrowsingHistory> oldestPage = browsingHistoryRepository.findByUserIdOrderByViewedAtDesc(userId, pageable);
            if (!oldestPage.isEmpty()) {
                browsingHistoryRepository.delete(oldestPage.getContent().get(0));
            }
        }

        BrowsingHistory history = new BrowsingHistory();
        history.setUserId(userId);
        history.setProductId(productId);
        browsingHistoryRepository.save(history);
    }

    public PageResponse<BrowsingHistoryItem> getBrowsingHistory(Integer userId, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("viewedAt").descending());
        Page<BrowsingHistory> historyPage = browsingHistoryRepository.findByUserIdOrderByViewedAtDesc(userId, pageable);

        List<BrowsingHistoryItem> items = historyPage.getContent().stream()
            .map(bh -> {
                Product product = productRepository.findById(bh.getProductId()).orElse(null);
                return new BrowsingHistoryItem(bh, product);
            })
            .collect(Collectors.toList());

        return new PageResponse<>(items, historyPage.getTotalElements());
    }

    public void deleteBrowsingHistory(Integer userId, Integer productId) {
        browsingHistoryRepository.deleteByUserIdAndProductId(userId, productId);
    }

    public void clearBrowsingHistory(Integer userId) {
        browsingHistoryRepository.deleteByUserId(userId);
    }
}
