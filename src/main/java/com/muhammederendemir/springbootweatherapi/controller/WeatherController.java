package com.muhammederendemir.springbootweatherapi.controller;

import com.muhammederendemir.springbootweatherapi.dto.WeatherDTO;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.Locale;

@RestController
public class WeatherController {


    @Autowired
    private RestTemplate restTemplate;


    @Value("${openweathermap.key}")
    private String key;


    @GetMapping(value = "/")
    public String getWelcomePage() {

        return "Muhammed Eren Demir";
    }

    @GetMapping(value = "/temperature")
    public WeatherDTO getCityWeather(String city) throws Exception {

        HttpHeaders headers=new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        HttpEntity<String> entity=new HttpEntity<String>(headers);

        String content=restTemplate.exchange("https://api.openweathermap.org/data/2.5/weather?q="+city+"&appid="+key, HttpMethod.GET,entity,String.class).getBody();

        JSONObject root = new JSONObject(content);

        JSONObject main = root.getJSONObject("main");
        float temp = Float.parseFloat(main.get("temp").toString());


        WeatherDTO weatherDTO=new WeatherDTO(temp);
        return weatherDTO;
    }
}
