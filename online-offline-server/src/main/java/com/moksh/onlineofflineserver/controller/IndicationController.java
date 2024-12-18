package com.moksh.onlineofflineserver.controller;

import com.moksh.onlineofflineserver.service.IndicatorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/v1/indicator")
@RequiredArgsConstructor
public class IndicationController {

    private final IndicatorService indicatorService;

    @PostMapping("/{username}")
    @CrossOrigin
    public ResponseEntity<Map<String, String>> heartbeat(@PathVariable("username") String username) {
        log.info("Received heartbeat request");
        Map<String, String> map = indicatorService.heartbeat(username);
        return ResponseEntity.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Methods", "POST, OPTIONS")
                .header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept").body(map);
    }

}
