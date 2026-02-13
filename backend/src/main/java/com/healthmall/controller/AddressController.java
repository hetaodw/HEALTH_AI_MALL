package com.healthmall.controller;

import com.healthmall.common.ApiResponse;
import com.healthmall.dto.AddressRequest;
import com.healthmall.entity.Address;
import com.healthmall.exception.BusinessException;
import com.healthmall.service.AddressService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/addresses")
public class AddressController {

    @Autowired
    private AddressService addressService;

    @GetMapping
    public ApiResponse<List<Address>> getMyAddresses(HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        List<Address> addresses = addressService.getUserAddresses(userId);
        return ApiResponse.success(addresses);
    }

    @GetMapping("/default")
    public ApiResponse<Address> getDefaultAddress(HttpServletRequest request) {
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        Address address = addressService.getDefaultAddress(userId);
        return ApiResponse.success(address);
    }

    @GetMapping("/{id}")
    public ApiResponse<Address> getAddress(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            Address address = addressService.getAddress(userId, id);
            return ApiResponse.success(address);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @PostMapping
    public ApiResponse<Address> createAddress(
            HttpServletRequest request,
            @RequestBody AddressRequest addressRequest) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            Address address = addressService.createAddress(userId, addressRequest);
            return ApiResponse.success(address);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ApiResponse<Address> updateAddress(
            HttpServletRequest request,
            @PathVariable Integer id,
            @RequestBody AddressRequest addressRequest) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            Address address = addressService.updateAddress(userId, id, addressRequest);
            return ApiResponse.success(address);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteAddress(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            addressService.deleteAddress(userId, id);
            return ApiResponse.success(null);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }

    @PostMapping("/{id}/default")
    public ApiResponse<Address> setDefaultAddress(
            HttpServletRequest request,
            @PathVariable Integer id) {
        
        Integer userId = (Integer) request.getAttribute("userId");
        if (userId == null) {
            return ApiResponse.error(401, "请先登录");
        }

        try {
            Address address = addressService.setDefaultAddress(userId, id);
            return ApiResponse.success(address);
        } catch (BusinessException e) {
            return ApiResponse.error(e.getCode(), e.getMessage());
        }
    }
}
