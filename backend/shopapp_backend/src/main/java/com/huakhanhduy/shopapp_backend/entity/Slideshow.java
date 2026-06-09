package com.huakhanhduy.shopapp_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "slideshows")
public class Slideshow extends BaseEntity {

    @Column(length = 80)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String destinationUrl;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String image;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String placeholder;

    @Column(length = 160)
    private String description;

    @Column(name = "btn_label", length = 50)
    private String btnLabel;

    @Column(nullable = false)
    private Integer displayOrder = 0;

    private Boolean published = false;

    @Column(nullable = false)
    private Integer clicks = 0;

    @Column(columnDefinition = "jsonb")
    private String styles;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private StaffAccount updatedBy;

    public Slideshow() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDestinationUrl() { return destinationUrl; }
    public void setDestinationUrl(String destinationUrl) { this.destinationUrl = destinationUrl; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }
    public String getPlaceholder() { return placeholder; }
    public void setPlaceholder(String placeholder) { this.placeholder = placeholder; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getBtnLabel() { return btnLabel; }
    public void setBtnLabel(String btnLabel) { this.btnLabel = btnLabel; }
    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }
    public Boolean getPublished() { return published; }
    public void setPublished(Boolean published) { this.published = published; }
    public Integer getClicks() { return clicks; }
    public void setClicks(Integer clicks) { this.clicks = clicks; }
    public String getStyles() { return styles; }
    public void setStyles(String styles) { this.styles = styles; }
    public StaffAccount getCreatedBy() { return createdBy; }
    public void setCreatedBy(StaffAccount createdBy) { this.createdBy = createdBy; }
    public StaffAccount getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(StaffAccount updatedBy) { this.updatedBy = updatedBy; }
}
