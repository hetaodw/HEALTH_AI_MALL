package com.healthmall.dto;

import com.healthmall.entity.User;

public class LoginResponse {
    private String token;
    private UserInfo userInfo;

    public LoginResponse(String token, User user) {
        this.token = token;
        this.userInfo = new UserInfo(user);
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public UserInfo getUserInfo() {
        return userInfo;
    }

    public void setUserInfo(UserInfo userInfo) {
        this.userInfo = userInfo;
    }

    public static class UserInfo {
        private Integer id;
        private String username;
        private String avatarUrl;

        public UserInfo(User user) {
            this.id = user.getId();
            this.username = user.getUsername();
            this.avatarUrl = user.getAvatarUrl();
        }

        public Integer getId() {
            return id;
        }

        public void setId(Integer id) {
            this.id = id;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getAvatarUrl() {
            return avatarUrl;
        }

        public void setAvatarUrl(String avatarUrl) {
            this.avatarUrl = avatarUrl;
        }
    }
}
