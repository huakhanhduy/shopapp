package com.huakhanhduy.shopapp_backend.impl;

import com.huakhanhduy.shopapp_backend.entity.Tag;
import com.huakhanhduy.shopapp_backend.repository.TagRepository;
import com.huakhanhduy.shopapp_backend.service.TagService;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class TagServiceImpl implements TagService {

    private final TagRepository tagRepository;

    public TagServiceImpl(
            TagRepository tagRepository
    ) {
        this.tagRepository = tagRepository;
    }

    @Override
    public List<Tag> getAllTags() {
        return tagRepository.findAll();
    }

    @Override
    public Tag getTagById(UUID id) {

        return tagRepository
                .findById(id)
                .orElseThrow(
                        () -> new RuntimeException(
                                "Tag not found"
                        )
                );
    }

    @Override
    public Tag createTag(Tag tag) {
        return tagRepository.save(tag);
    }

    @Override
    public Tag updateTag(
            UUID id,
            Tag tag
    ) {

        Tag existing =
                tagRepository
                        .findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Tag not found"
                                )
                        );

        existing.setTagName(
                tag.getTagName()
        );

        existing.setIcon(
                tag.getIcon()
        );

        return tagRepository.save(existing);
    }

    @Override
    public void deleteTag(UUID id) {

        Tag existing =
                tagRepository
                        .findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Tag not found"
                                )
                        );

        tagRepository.delete(existing);
    }
}