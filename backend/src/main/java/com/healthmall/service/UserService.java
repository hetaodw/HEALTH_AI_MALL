package com.healthmall.service;

import com.healthmall.entity.User;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User getUserProfile(Integer userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(401, "用户不存在"));
    }

    public void updateUserProfile(Integer userId, String avatarUrl, String remarks) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(401, "用户不存在"));

        if (avatarUrl != null) {
            user.setAvatarUrl(avatarUrl);
        }
        if (remarks != null) {
            user.setRemarks(remarks);
        }

        userRepository.save(user);
    }
}
