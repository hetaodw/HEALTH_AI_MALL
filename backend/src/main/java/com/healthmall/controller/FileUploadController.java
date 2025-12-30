package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.service.FileUploadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/upload")
public class FileUploadController {

    @Autowired
    private FileUploadService fileUploadService;

    @PostMapping("/avatar")
    public ApiResponse<Map<String, String>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        try {
            String fileUrl = fileUploadService.uploadFile(file, "avatar");
            Map<String, String> data = new HashMap<>();
            data.put("url", fileUrl);
            return ApiResponse.success(data);
        } catch (IOException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PostMapping("/product/cover")
    public ApiResponse<Map<String, String>> uploadProductCover(@RequestParam("file") MultipartFile file) {
        try {
            String fileUrl = fileUploadService.uploadFile(file, "product/cover");
            Map<String, String> data = new HashMap<>();
            data.put("url", fileUrl);
            return ApiResponse.success(data);
        } catch (IOException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @PostMapping("/product/detail")
    public ApiResponse<Map<String, String>> uploadProductDetail(@RequestParam("file") MultipartFile file) {
        try {
            String fileUrl = fileUploadService.uploadFile(file, "product/detail");
            Map<String, String> data = new HashMap<>();
            data.put("url", fileUrl);
            return ApiResponse.success(data);
        } catch (IOException e) {
            return ApiResponse.error(400, e.getMessage());
        }
    }

    @DeleteMapping
    public ApiResponse<Void> deleteFile(@RequestParam("url") String fileUrl) {
        boolean deleted = fileUploadService.deleteFile(fileUrl);
        if (deleted) {
            return ApiResponse.success();
        } else {
            return ApiResponse.error(400, "文件删除失败");
        }
    }
}
