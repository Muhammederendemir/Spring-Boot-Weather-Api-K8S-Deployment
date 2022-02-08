package com.muhammederendemir.springbootweatherapi;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.muhammederendemir.springbootweatherapi.controller.WeatherController;
import com.muhammederendemir.springbootweatherapi.dto.WeatherDTO;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;


@SpringBootTest
@AutoConfigureMockMvc
class SpringBootWeatherApiApplicationTests {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper mapper;


    @MockBean
    WeatherController weatherController;

    @Test
    void should_return_get_temp_integration() throws Exception {

        WeatherDTO weatherDTO=new WeatherDTO(2.75f);


        Mockito.when(weatherController.getCityWeather("sivas")).thenReturn(weatherDTO);

        MvcResult mvcResult = this.mockMvc.perform(MockMvcRequestBuilders
                        .get("/temperature?city=sivas"))
                .andReturn();

        WeatherDTO actualResponse =  mapper.readValue(mvcResult.getResponse().getContentAsString().toString(), WeatherDTO.class);

        assertNotNull(actualResponse);
        assertNotNull(actualResponse.getTemperature());
        assertEquals(200  ,mvcResult.getResponse().getStatus());
    }

}
