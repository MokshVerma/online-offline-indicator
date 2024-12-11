package com.moksh.onlineofflineserver.repository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.time.Duration;
import java.util.Map;

@Slf4j
@Repository
@RequiredArgsConstructor
public class RedisRepository {

    private final RedisTemplate redisTemplate;

    public void insertHash(String key, String value) {
        redisTemplate.opsForHash().put("user-last-seen", key, value);
        redisTemplate.expire(key, Duration.ofMillis(5000L));
        log.info("Inserted key: {} and value: {}", key, value);
    }

    public Map<String, String> getAllHash() {
        return redisTemplate.opsForHash().entries("user-last-seen");
    }

    public String getHash(String key, String value) {
        log.info("Getting key: {} and value: {}", key, value);
        return (String) redisTemplate.opsForHash().get("user-last-seen", key);
    }

}
