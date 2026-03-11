package com.healthmall.aspect;

import com.healthmall.annotation.Idempotent;
import com.healthmall.exception.BusinessException;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.concurrent.TimeUnit;

@Aspect
@Component
public class IdempotentAspect {
    
    @Autowired
    private StringRedisTemplate stringRedisTemplate;
    
    @Around("@annotation(idempotent)")
    public Object around(ProceedingJoinPoint joinPoint, Idempotent idempotent) throws Throwable {
        HttpServletRequest request = getRequest();
        
        String key = buildKey(joinPoint, idempotent, request);
        
        Boolean isNew = stringRedisTemplate.opsForValue().setIfAbsent(
            key, 
            "1", 
            idempotent.expireSeconds(), 
            TimeUnit.SECONDS
        );
        
        if (Boolean.FALSE.equals(isNew)) {
            throw new BusinessException(400, idempotent.message());
        }
        
        try {
            return joinPoint.proceed();
        } catch (Exception e) {
            stringRedisTemplate.delete(key);
            throw e;
        }
    }
    
    private String buildKey(ProceedingJoinPoint joinPoint, Idempotent idempotent, HttpServletRequest request) {
        String prefix = "idempotent:";
        
        if (!idempotent.key().isEmpty()) {
            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            String methodName = signature.getDeclaringType().getSimpleName() + "." + signature.getName();
            
            String userId = request.getAttribute("userId") != null ? request.getAttribute("userId").toString() : "anonymous";
            String token = request.getHeader("Authorization");
            
            return prefix + methodName + ":" + userId + ":" + System.identityHashCode(token);
        }
        
        return prefix + idempotent.key();
    }
    
    private HttpServletRequest getRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }
}
