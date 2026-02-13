package com.healthmall.repository;

import com.healthmall.entity.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AddressRepository extends JpaRepository<Address, Integer> {
    
    List<Address> findByUserIdOrderByIsDefaultDescCreatedAtDesc(Integer userId);
    
    Optional<Address> findByUserIdAndIsDefaultTrue(Integer userId);
    
    void deleteByUserIdAndIsDefaultTrue(Integer userId);
}
