package com.healthmall;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class HealthMallApplication {
    public static void main(String[] args) {
        SpringApplication.run(HealthMallApplication.class, args);
    }
}
