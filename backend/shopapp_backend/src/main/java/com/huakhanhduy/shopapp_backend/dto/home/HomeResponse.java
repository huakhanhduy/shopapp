package com.huakhanhduy.shopapp_backend.dto.home;

import java.util.List;

public class HomeResponse {

    private List<String> banners;

    private List<HomeSectionResponse> sections;

    public HomeResponse() {
    }

    public List<String> getBanners() {
        return banners;
    }

    public void setBanners(List<String> banners) {
        this.banners = banners;
    }

    public List<HomeSectionResponse> getSections() {
        return sections;
    }

    public void setSections(
            List<HomeSectionResponse> sections
    ) {
        this.sections = sections;
    }
}