package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.service.FileUploadService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/upload")
public class UploadController {

    @Autowired
    private FileUploadService fileUploadService;

    @PostMapping("/image")
    public ApiResponse<Map<String, String>> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", required = false, defaultValue = "uploads") String type,
            HttpServletRequest request) {
        
        try {
            // 验证用户是否登录
            String token = request.getHeader("Authorization");
            if (token == null || token.isEmpty()) {
                return ApiResponse.error(401, "请先登录");
            }

            String url = fileUploadService.uploadImage(file, type);
            
            Map<String, String> data = new HashMap<>();
            data.put("url", url);
            
            return ApiResponse.success("上传成功", data);
        } catch (IOException e) {
            return ApiResponse.error(500, "文件上传失败: " + e.getMessage());
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }
}
