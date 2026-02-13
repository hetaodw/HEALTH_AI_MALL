package com.healthmall.service;

import com.healthmall.dto.AddressRequest;
import com.healthmall.entity.Address;
import com.healthmall.exception.BusinessException;
import com.healthmall.repository.AddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AddressService {

    @Autowired
    private AddressRepository addressRepository;

    public List<Address> getUserAddresses(Integer userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId);
    }

    public Address getAddress(Integer userId, Integer addressId) {
        Address address = addressRepository.findById(addressId)
                .orElseThrow(() -> new BusinessException(404, "地址不存在"));
        
        if (!address.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权访问此地址");
        }
        
        return address;
    }

    @Transactional
    public Address createAddress(Integer userId, AddressRequest request) {
        Address address = new Address();
        address.setUserId(userId);
        address.setReceiverName(request.getReceiverName());
        address.setReceiverPhone(request.getReceiverPhone());
        address.setProvince(request.getProvince());
        address.setCity(request.getCity());
        address.setDistrict(request.getDistrict());
        address.setDetailAddress(request.getDetailAddress());
        
        if (Boolean.TRUE.equals(request.getIsDefault())) {
            addressRepository.deleteByUserIdAndIsDefaultTrue(userId);
            address.setIsDefault(true);
        } else {
            address.setIsDefault(false);
        }
        
        return addressRepository.save(address);
    }

    @Transactional
    public Address updateAddress(Integer userId, Integer addressId, AddressRequest request) {
        Address address = getAddress(userId, addressId);
        
        address.setReceiverName(request.getReceiverName());
        address.setReceiverPhone(request.getReceiverPhone());
        address.setProvince(request.getProvince());
        address.setCity(request.getCity());
        address.setDistrict(request.getDistrict());
        address.setDetailAddress(request.getDetailAddress());
        
        if (Boolean.TRUE.equals(request.getIsDefault()) && !Boolean.TRUE.equals(address.getIsDefault())) {
            addressRepository.deleteByUserIdAndIsDefaultTrue(userId);
            address.setIsDefault(true);
        }
        
        return addressRepository.save(address);
    }

    @Transactional
    public void deleteAddress(Integer userId, Integer addressId) {
        Address address = getAddress(userId, addressId);
        addressRepository.delete(address);
    }

    @Transactional
    public Address setDefaultAddress(Integer userId, Integer addressId) {
        Address address = getAddress(userId, addressId);
        
        addressRepository.deleteByUserIdAndIsDefaultTrue(userId);
        address.setIsDefault(true);
        
        return addressRepository.save(address);
    }

    public Address getDefaultAddress(Integer userId) {
        return addressRepository.findByUserIdAndIsDefaultTrue(userId).orElse(null);
    }
}
