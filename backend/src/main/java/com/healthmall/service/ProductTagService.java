package com.healthmall.service;

import com.healthmall.dto.BatchGenerateRequest;
import com.healthmall.dto.BatchGenerateResponse;
import com.healthmall.dto.PageResponse;
import com.healthmall.dto.ProductListItem;
import com.healthmall.dto.TagStatistics;
import com.healthmall.entity.Product;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProductTagService {

    private static final Logger logger = LoggerFactory.getLogger(ProductTagService.class);

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private AiTagGenerator aiTagGenerator;

    public List<String> generateTagsForProduct(Integer productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        List<String> tags = aiTagGenerator.generateTags(product.getTitle(), product.getDescription());
        
        if (!tags.isEmpty()) {
            product.setTags(tags);
            product.setNeedRegenerateTags(false);
            productRepository.save(product);
            logger.info("商品标签生成成功: productId={}, tags={}", productId, tags);
        } else {
            logger.warn("商品标签生成失败或返回空: productId={}", productId);
        }
        
        return tags;
    }

    @Transactional
    public BatchGenerateResponse generateTagsForProducts(List<Integer> productIds) {
        BatchGenerateResponse response = new BatchGenerateResponse();
        response.setSuccessCount(0);
        response.setFailedCount(0);
        response.setFailedProductIds(new ArrayList<>());

        for (Integer productId : productIds) {
            try {
                generateTagsForProduct(productId);
                response.setSuccessCount(response.getSuccessCount() + 1);
            } catch (Exception e) {
                logger.error("批量生成标签失败: productId={}, error={}", productId, e.getMessage());
                response.setFailedCount(response.getFailedCount() + 1);
                response.getFailedProductIds().add(productId);
            }
        }

        response.setMessage(String.format("批量生成完成：成功%d个，失败%d个", 
            response.getSuccessCount(), response.getFailedCount()));

        return response;
    }

    public List<String> getProductTags(Integer productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));
        return product.getTags();
    }

    @Transactional
    public void updateProductTags(Integer productId, List<String> tags) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));

        product.setTags(tags);
        product.setNeedRegenerateTags(false);
        productRepository.save(product);
        
        logger.info("商品标签手动更新成功: productId={}, tags={}", productId, tags);
    }

    public List<TagStatistics> getPopularTags(Integer limit) {
        List<Product> allProducts = productRepository.findAll();
        Map<String, Integer> tagCountMap = new HashMap<>();

        for (Product product : allProducts) {
            List<String> tags = product.getTags();
            for (String tag : tags) {
                if (tag != null && !tag.trim().isEmpty() && !tag.startsWith("{") && !tag.startsWith("[")) {
                    tagCountMap.put(tag, tagCountMap.getOrDefault(tag, 0) + 1);
                }
            }
        }

        List<TagStatistics> statistics = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : tagCountMap.entrySet()) {
            TagStatistics stat = new TagStatistics();
            stat.setTag(entry.getKey());
            Integer cnt = entry.getValue();
            stat.setCount(cnt != null ? cnt : 0);
            statistics.add(stat);
        }
        
        statistics.sort((a, b) -> Integer.compare(b.getCount(), a.getCount()));
        
        return statistics.stream().limit(limit).collect(Collectors.toList());
    }

    public PageResponse<ProductListItem> searchByTags(List<String> tags, Integer page, Integer size) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        
        List<Product> allProducts = productRepository.findAll();
        List<Product> filteredProducts = allProducts.stream()
                .filter(product -> {
                    List<String> productTags = product.getTags();
                    return productTags.stream().anyMatch(tags::contains);
                })
                .collect(Collectors.toList());

        int start = (page - 1) * size;
        int end = Math.min(start + size, filteredProducts.size());
        
        List<Product> pageProducts = filteredProducts.subList(start, end);
        List<ProductListItem> items = pageProducts.stream()
                .map(ProductListItem::new)
                .collect(Collectors.toList());

        return new PageResponse<>(items, (long) filteredProducts.size());
    }

    @Transactional
    public void processPendingRegenerateTags(int batchSize) {
        List<Product> pendingProducts = productRepository.findByNeedRegenerateTagsTrueOrderByUpdatedAtAsc();
        
        if (pendingProducts.isEmpty()) {
            logger.info("没有需要重新生成标签的商品");
            return;
        }

        logger.info("开始处理需要重新生成标签的商品，共{}个", pendingProducts.size());

        int processedCount = 0;
        for (Product product : pendingProducts) {
            if (processedCount >= batchSize) {
                logger.info("已达到批次处理上限，本次处理{}个商品", processedCount);
                break;
            }

            try {
                List<String> tags = aiTagGenerator.generateTags(product.getTitle(), product.getDescription());
                if (!tags.isEmpty()) {
                    product.setTags(tags);
                    product.setNeedRegenerateTags(false);
                    productRepository.save(product);
                    processedCount++;
                    logger.info("商品标签重新生成成功: productId={}, tags={}", product.getId(), tags);
                } else {
                    logger.warn("商品标签重新生成失败或返回空: productId={}", product.getId());
                }
            } catch (Exception e) {
                logger.error("商品标签重新生成异常: productId={}, error={}", product.getId(), e.getMessage());
            }
        }

        logger.info("需要重新生成标签的商品处理完成，成功{}个", processedCount);
    }

    public void markForRegenerateTags(Integer productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BusinessException(404, "商品不存在"));
        product.setNeedRegenerateTags(true);
        productRepository.save(product);
        logger.info("商品已标记为需要重新生成标签: productId={}", productId);
    }
}
