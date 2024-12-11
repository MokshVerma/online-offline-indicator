package com.moksh.onlineofflineserver.service.impl;

import com.moksh.onlineofflineserver.repository.RedisRepository;
import com.moksh.onlineofflineserver.service.IndicatorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class IndicatorServiceImpl implements IndicatorService {

    private final RedisRepository redisRepository;

    @Override
    public Map<String, String> heartbeat(String username) {
        log.info("Received heartbeat request");
        redisRepository.insertHash(username, String.valueOf(Instant.now().toEpochMilli()));
        Map<String, String> map = redisRepository.getAllHash();

        for (String key : map.keySet()) {
            if (Long.parseLong(map.get(key)) + 5000L >= Instant.now().toEpochMilli()) {
                map.put(key, "online");
            } else {
                map.put(key, relativeTime(map.get(key)));
            }
        }
        return map;
    }

    private String relativeTime(String epoch) {
        long time = Long.parseLong(epoch);
        long currentTime = Instant.now().toEpochMilli();
        if (currentTime - time < 60000L) {
            return "last seen " + (currentTime - time - 5000L) / 1000L + " seconds ago";
        } else if (currentTime - time < 3600000L) {
            return "last seen " + (currentTime - time) / 60000L + " minutes ago";
        } else if (currentTime - time < 86400000L) {
            return "last seen " + (currentTime - time) / 3600000L + " hours ago";
        } else {
            return "last seen " + (currentTime - time) / 86400000L + " days ago";
        }
    }
}
