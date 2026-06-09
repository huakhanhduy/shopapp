package com.huakhanhduy.shopapp_backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve assets/images from the local frontend asset folder
        Path pathImages = Paths.get("../../frontend/shopapp_frontend/assets/images/");
        String absolutePathImages = pathImages.toFile().getAbsolutePath();
        registry.addResourceHandler("/assets/images/**")
                .addResourceLocations("file:" + absolutePathImages + "/");

        // Serve assets/uploads from the local frontend uploads folder
        Path pathUploads = Paths.get("../../frontend/shopapp_frontend/assets/uploads/");
        String absolutePathUploads = pathUploads.toFile().getAbsolutePath();
        registry.addResourceHandler("/assets/uploads/**")
                .addResourceLocations("file:" + absolutePathUploads + "/");
    }
}
