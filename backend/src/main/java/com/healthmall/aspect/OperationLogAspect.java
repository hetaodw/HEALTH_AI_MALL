package com.healthmall.aspect;

import com.alibaba.fastjson2.JSON;
import com.healthmall.entity.OperationLog;
import com.healthmall.repository.OperationLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Arrays;

@Aspect
@Component
public class OperationLogAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(OperationLogAspect.class);
    
    @Autowired
    private OperationLogRepository operationLogRepository;
    
    @Around("@annotation(operationLog)")
    public Object around(ProceedingJoinPoint joinPoint, com.healthmall.annotation.OperationLog operationLog) throws Throwable {
        long startTime = System.currentTimeMillis();
        HttpServletRequest request = getRequest();
        
        OperationLog logEntity = new OperationLog();
        
        try {
            Object result = joinPoint.proceed();
            
            long executeTime = System.currentTimeMillis() - startTime;
            
            fillLogInfo(joinPoint, operationLog, request, logEntity, executeTime, "SUCCESS", null, result);
            
            saveLogAsync(logEntity);
            
            return result;
        } catch (Exception e) {
            long executeTime = System.currentTimeMillis() - startTime;
            
            fillLogInfo(joinPoint, operationLog, request, logEntity, executeTime, "FAILED", e.getMessage(), null);
            
            saveLogAsync(logEntity);
            
            throw e;
        }
    }
    
    private void fillLogInfo(ProceedingJoinPoint joinPoint, com.healthmall.annotation.OperationLog operationLog, 
                          HttpServletRequest request, OperationLog logEntity, 
                          long executeTime, String status, String errorMessage, Object result) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        
        Integer userId = request != null ? (Integer) request.getAttribute("userId") : null;
        String username = request != null ? (String) request.getAttribute("username") : null;
        
        logEntity.setUserId(userId);
        logEntity.setUsername(username);
        logEntity.setModule(operationLog.module());
        logEntity.setOperation(operationLog.operation());
        logEntity.setDescription(operationLog.description());
        logEntity.setRequestMethod(request != null ? request.getMethod() : null);
        logEntity.setRequestUrl(request != null ? request.getRequestURI() : null);
        logEntity.setRequestParams(request != null ? JSON.toJSONString(filterSerializableArgs(joinPoint.getArgs())) : null);
        logEntity.setResponseData(result != null ? JSON.toJSONString(result) : null);
        logEntity.setIpAddress(request != null ? getClientIp(request) : null);
        logEntity.setExecuteTime(executeTime);
        logEntity.setStatus(status);
        logEntity.setErrorMessage(errorMessage);
    }
    
    @Async
    public void saveLogAsync(OperationLog logEntity) {
        try {
            operationLogRepository.save(logEntity);
        } catch (Exception e) {
            logger.error("保存操作日志失败", e);
        }
    }
    
    private HttpServletRequest getRequest() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attributes != null ? attributes.getRequest() : null;
    }
    
    private Object[] filterSerializableArgs(Object[] args) {
        if (args == null || args.length == 0) {
            return args;
        }
        
        Object[] filteredArgs = new Object[args.length];
        for (int i = 0; i < args.length; i++) {
            Object arg = args[i];
            if (arg == null) {
                filteredArgs[i] = null;
            } else if (arg instanceof jakarta.servlet.http.HttpServletRequest 
                    || arg instanceof jakarta.servlet.http.HttpServletResponse
                    || arg instanceof org.springframework.web.multipart.MultipartFile) {
                filteredArgs[i] = "[Non-serializable: " + arg.getClass().getSimpleName() + "]";
            } else {
                filteredArgs[i] = arg;
            }
        }
        return filteredArgs;
    }
    
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip != null ? ip.split(",")[0] : null;
    }
}
