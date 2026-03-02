package com.healthmall.interceptor;

import com.healthmall.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(AuthInterceptor.class);

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String requestUri = request.getRequestURI();
        String method = request.getMethod();
        logger.info("AuthInterceptor - {} {}", method, requestUri);
        
        String token = request.getHeader("Authorization");

        if (token == null || !token.startsWith("Bearer ")) {
            logger.warn("AuthInterceptor - No valid token found for {} {}", method, requestUri);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"未登录或Token已过期\",\"data\":null}");
            return false;
        }

        token = token.substring(7);

        if (!jwtUtil.validateToken(token)) {
            logger.warn("AuthInterceptor - Invalid token for {} {}", method, requestUri);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"msg\":\"未登录或Token已过期\",\"data\":null}");
            return false;
        }

        Integer userId = jwtUtil.getUserIdFromToken(token);
        logger.info("AuthInterceptor - Token validated - userId: {} for {} {}", userId, method, requestUri);
        request.setAttribute("userId", userId);

        return true;
    }
}
