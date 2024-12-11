package com.moksh.onlineofflineserver.service;

import java.util.Map;

public interface IndicatorService {

    Map<String, String> heartbeat(String username);

}
