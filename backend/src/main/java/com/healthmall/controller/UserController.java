package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.entity.User;
import com.healthmall.service.FileUploadService;
import com.healthmall.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private FileUploadService fileUploadService;

    @GetMapping("/profile")
    public ApiResponse<User> getUserProfile(HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        User user = userService.getUserProfile(userId);
        return ApiResponse.success(user);
    }

    @PutMapping("/profile/update")
    public ApiResponse<Void> updateUserProfile(
            HttpServletRequest request,
            @RequestParam(required = false) String avatarUrl,
            @RequestParam(required = false) String remarks) {
        Integer userId = (Integer) request.getAttribute("userId");
        userService.updateUserProfile(userId, avatarUrl, remarks);
        return ApiResponse.success();
    }

    @PostMapping("/avatar/upload")
    public ApiResponse<Map<String, String>> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            HttpServletRequest request) {
        
        try {
            Integer userId = (Integer) request.getAttribute("userId");
            if (userId == null) {
                return ApiResponse.error(401, "请先登录");
            }

            // 上传头像图片
            String avatarUrl = fileUploadService.uploadImage(file, "avatar");
            
            // 更新用户头像URL
            userService.updateUserProfile(userId, avatarUrl, null);
            
            Map<String, String> data = new HashMap<>();
            data.put("avatarUrl", avatarUrl);
            
            return ApiResponse.success("头像上传成功", data);
        } catch (IOException e) {
            return ApiResponse.error(500, "文件上传失败: " + e.getMessage());
        } catch (RuntimeException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }
}
