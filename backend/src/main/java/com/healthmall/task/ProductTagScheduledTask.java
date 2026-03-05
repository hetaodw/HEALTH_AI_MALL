package com.healthmall.task;

import com.healthmall.service.ProductTagService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ProductTagScheduledTask {

    private static final Logger logger = LoggerFactory.getLogger(ProductTagScheduledTask.class);

    @Autowired
    private ProductTagService productTagService;

    @Value("${product.tag.batch.size:50}")
    private int batchSize;

    @Value("${product.tag.task.enabled:true}")
    private boolean taskEnabled;

    @Scheduled(cron = "${product.tag.task.cron:0 0 */2 * * ?}")
    public void regenerateTags() {
        if (!taskEnabled) {
            logger.debug("商品标签定时任务已禁用");
            return;
        }

        logger.info("开始执行商品标签重新生成定时任务，批次大小：{}", batchSize);

        try {
            productTagService.processPendingRegenerateTags(batchSize);
            logger.info("商品标签重新生成定时任务执行完成");
        } catch (Exception e) {
            logger.error("商品标签重新生成定时任务执行失败", e);
        }
    }
}
