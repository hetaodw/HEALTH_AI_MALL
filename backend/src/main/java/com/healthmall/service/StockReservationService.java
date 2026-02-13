package com.healthmall.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.concurrent.TimeUnit;

/**
 * 库存预占服务
 * 使用Redis + Lua脚本实现原子操作，防止超卖
 */
@Service
public class StockReservationService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    private static final String STOCK_KEY_PREFIX = "stock:product:";
    private static final String RESERVATION_KEY_PREFIX = "reservation:";
    private static final long RESERVATION_TIMEOUT_MINUTES = 15;

    private static final String LUA_RESERVE_STOCK = """
            local stockKey = KEYS[1]
            local reservationKey = KEYS[2]
            local quantity = tonumber(ARGV[1])
            local expireSeconds = tonumber(ARGV[2])
            
            local currentStock = tonumber(redis.call('GET', stockKey))
            if currentStock == nil then
                return -1
            end
            
            if currentStock < quantity then
                return -2
            end
            
            redis.call('DECRBY', stockKey, quantity)
            redis.call('SETEX', reservationKey, expireSeconds, quantity)
            
            return 1
            """;

    private static final String LUA_CONFIRM_STOCK = """
            local stockKey = KEYS[1]
            local reservationKey = KEYS[2]
            
            local reserved = redis.call('GET', reservationKey)
            if reserved == nil then
                return -1
            end
            
            redis.call('DEL', reservationKey)
            return 1
            """;

    private static final String LUA_RELEASE_STOCK = """
            local stockKey = KEYS[1]
            local reservationKey = KEYS[2]
            
            local reserved = redis.call('GET', reservationKey)
            if reserved == nil then
                return -1
            end
            
            local quantity = tonumber(reserved)
            redis.call('INCRBY', stockKey, quantity)
            redis.call('DEL', reservationKey)
            
            return 1
            """;

    public void initStock(Integer productId, Integer stock) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        redisTemplate.opsForValue().set(stockKey, String.valueOf(stock));
    }

    public Integer getStock(Integer productId) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        String stock = redisTemplate.opsForValue().get(stockKey);
        return stock != null ? Integer.parseInt(stock) : null;
    }

    public boolean reserveStock(Integer productId, String orderNo, Integer quantity) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        String reservationKey = RESERVATION_KEY_PREFIX + orderNo + ":" + productId;
        
        DefaultRedisScript<Long> script = new DefaultRedisScript<>(LUA_RESERVE_STOCK, Long.class);
        Long result = redisTemplate.execute(
                script,
                java.util.Arrays.asList(stockKey, reservationKey),
                String.valueOf(quantity),
                String.valueOf(RESERVATION_TIMEOUT_MINUTES * 60)
        );
        
        if (result != null) {
            if (result == 1) {
                return true;
            } else if (result == -2) {
                throw new RuntimeException("库存不足");
            } else if (result == -1) {
                throw new RuntimeException("商品库存未初始化");
            }
        }
        return false;
    }

    public boolean confirmReservation(Integer productId, String orderNo) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        String reservationKey = RESERVATION_KEY_PREFIX + orderNo + ":" + productId;
        
        DefaultRedisScript<Long> script = new DefaultRedisScript<>(LUA_CONFIRM_STOCK, Long.class);
        Long result = redisTemplate.execute(
                script,
                java.util.Arrays.asList(stockKey, reservationKey)
        );
        
        return result != null && result == 1;
    }

    public boolean releaseReservation(Integer productId, String orderNo) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        String reservationKey = RESERVATION_KEY_PREFIX + orderNo + ":" + productId;
        
        DefaultRedisScript<Long> script = new DefaultRedisScript<>(LUA_RELEASE_STOCK, Long.class);
        Long result = redisTemplate.execute(
                script,
                java.util.Arrays.asList(stockKey, reservationKey)
        );
        
        return result != null && result == 1;
    }

    public void syncStockFromDb(Integer productId, Integer dbStock) {
        String stockKey = STOCK_KEY_PREFIX + productId;
        String currentStock = redisTemplate.opsForValue().get(stockKey);
        
        if (currentStock == null) {
            initStock(productId, dbStock);
        }
    }
}
