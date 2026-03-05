package com.healthmall.service;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiTagGenerator {

    private static final Logger logger = LoggerFactory.getLogger(AiTagGenerator.class);

    @Value("${ai.service.url:http://localhost:5001}")
    private String aiServiceUrl;

    @Value("${ai.service.timeout:30000}")
    private int timeout;

    private final RestTemplate restTemplate;

    public AiTagGenerator() {
        this.restTemplate = new RestTemplate();
    }

    public List<String> generateTags(String title, String description) {
        try {
            logger.info("开始生成标签: title={}, description={}", title, description);
            String prompt = buildPrompt(title, description);
            String response = callAiModel(prompt);
            logger.info("AI服务返回原始响应: {}", response);
            List<String> tags = parseTags(response);
            logger.info("解析后的标签: {}", tags);
            return tags;
        } catch (Exception e) {
            logger.error("AI标签生成失败: title={}, description={}, error={}", title, description, e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    private String buildPrompt(String title, String description) {
        return String.format("请为以下商品生成3-5个标签，标签要简洁、准确、有代表性。\n\n商品标题：%s\n商品描述：%s\n\n请直接返回JSON数组格式的标签列表，例如：[\"标签1\", \"标签2\", \"标签3\"]", 
            title, description != null ? description : "");
    }

    private String callAiModel(String prompt) {
        try {
            String url = aiServiceUrl + "/api/generate-tags";
            
            Map<String, String> requestBody = new HashMap<>();
            requestBody.put("prompt", prompt);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<String> entity = new HttpEntity<>(JSON.toJSONString(requestBody), headers);
            
            ResponseEntity<String> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                String.class
            );
            
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                return response.getBody();
            } else {
                logger.warn("AI服务返回异常状态: {}", response.getStatusCode());
                return "[]";
            }
        } catch (Exception e) {
            logger.error("调用AI服务失败: {}", e.getMessage());
            return "[]";
        }
    }

    private List<String> parseTags(String response) {
        try {
            if (response == null || response.trim().isEmpty()) {
                logger.warn("AI服务返回空响应");
                return new ArrayList<>();
            }
            
            logger.info("开始解析AI响应，原始内容: {}", response);
            
            Map<String, Object> result = JSON.parseObject(response, Map.class);
            Object tagsObj = result.get("tags");
            
            if (tagsObj instanceof JSONArray) {
                JSONArray tagsArray = (JSONArray) tagsObj;
                List<String> tags = new ArrayList<>();
                for (int i = 0; i < tagsArray.size(); i++) {
                    String tag = tagsArray.getString(i);
                    if (tag != null && !tag.trim().isEmpty() && !tag.startsWith("{") && !tag.startsWith("[")) {
                        tags.add(tag.trim());
                    }
                }
                logger.info("从JSONArray解析到{}个标签", tags.size());
                return tags;
            } else if (tagsObj instanceof List) {
                List<String> tags = (List<String>) tagsObj;
                List<String> resultTags = new ArrayList<>();
                for (String tag : tags) {
                    if (tag != null && !tag.trim().isEmpty() && !tag.startsWith("{") && !tag.startsWith("[")) {
                        resultTags.add(tag.trim());
                    }
                }
                logger.info("从List解析到{}个标签", resultTags.size());
                return resultTags;
            }
            
            logger.warn("无法解析AI响应中的tags字段，类型: {}", tagsObj != null ? tagsObj.getClass().getName() : "null");
            return new ArrayList<>();
        } catch (Exception e) {
            logger.error("解析AI返回结果失败: {}, error: {}", response, e.getMessage(), e);
            return new ArrayList<>();
        }
    }
}
