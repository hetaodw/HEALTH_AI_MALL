package com.healthmall.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
public class FileUploadService {

    @Value("${file.upload.path:/app/static}")
    private String uploadPath;

    @Value("${file.access.url:http://localhost/v1/static}")
    private String accessUrl;

    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    public String uploadImage(MultipartFile file, String type) throws IOException {
        // 验证文件是否为空
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("文件不能为空");
        }

        // 验证文件大小
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new RuntimeException("文件大小不能超过5MB");
        }

        // 验证文件类型
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) {
            throw new RuntimeException("文件名不能为空");
        }

        String extension = getFileExtension(originalFilename).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new RuntimeException("不支持的文件格式，仅支持: " + String.join(", ", ALLOWED_EXTENSIONS));
        }

        // 确定存储路径
        String subPath = determineSubPath(type);
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String directory = uploadPath + "/" + subPath + "/" + datePath;

        // 创建目录
        Path dirPath = Paths.get(directory);
        if (!Files.exists(dirPath)) {
            Files.createDirectories(dirPath);
        }

        // 生成唯一文件名
        String newFilename = UUID.randomUUID().toString().replace("-", "") + "." + extension;
        Path filePath = dirPath.resolve(newFilename);

        // 保存文件
        Files.copy(file.getInputStream(), filePath);

        // 返回访问URL
        return accessUrl + "/" + subPath + "/" + datePath + "/" + newFilename;
    }

    private String getFileExtension(String filename) {
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex == -1 || lastDotIndex == filename.length() - 1) {
            throw new RuntimeException("文件没有扩展名");
        }
        return filename.substring(lastDotIndex + 1);
    }

    private String determineSubPath(String type) {
        if (type == null) {
            return "uploads";
        }

        switch (type.toLowerCase()) {
            case "avatar":
                return "user/avatar";
            case "product-cover":
                return "product/cover";
            case "product-detail":
                return "product/detail";
            default:
                return "uploads";
        }
    }
}
