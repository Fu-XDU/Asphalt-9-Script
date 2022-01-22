package com.script.a9script;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@Slf4j
@SpringBootApplication
public class A9scriptApplication {

    public static void main(String[] args) {
        SpringApplication.run(A9scriptApplication.class, args);
        log.info("Server listening on http://127.0.0.1:8081");
    }

}
