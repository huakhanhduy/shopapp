package com.huakhanhduy.shopapp_backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.*;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

        @Bean
        public CorsConfigurationSource corsConfigurationSource() {

                CorsConfiguration config = new CorsConfiguration();

                config.addAllowedOriginPattern("*");
                config.addAllowedMethod("*");
                config.addAllowedHeader("*");

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();

                source.registerCorsConfiguration(
                                "/**",
                                config);

                return source;
        }

        @Bean
        public WebMvcConfigurer corsConfigurer() {

                return new WebMvcConfigurer() {

                        @Override
                        public void addCorsMappings(
                                        CorsRegistry registry) {

                                registry.addMapping("/**")
                                                .allowedOrigins("*")
                                                .allowedMethods("*")
                                                .allowedHeaders("*");
                        }
                };
        }

}