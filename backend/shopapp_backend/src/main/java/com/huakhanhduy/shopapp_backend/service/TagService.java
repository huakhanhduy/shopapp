package com.huakhanhduy.shopapp_backend.service;

import com.huakhanhduy.shopapp_backend.entity.Tag;

import java.util.List;
import java.util.UUID;

public interface TagService {

    List<Tag> getAllTags();

    Tag getTagById(UUID id);

    Tag createTag(Tag tag);

    Tag updateTag(
            UUID id,
            Tag tag
    );

    void deleteTag(UUID id);
}