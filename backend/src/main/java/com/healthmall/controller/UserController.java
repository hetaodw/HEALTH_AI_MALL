package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.entity.User;
import com.healthmall.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

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
}
