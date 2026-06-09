package com.huakhanhduy.shopapp_backend.controller;

import com.huakhanhduy.shopapp_backend.entity.Tag;
import com.huakhanhduy.shopapp_backend.service.TagService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tags")
@CrossOrigin("*")
public class TagController {

    private final TagService tagService;

    public TagController(
            TagService tagService
    ) {
        this.tagService = tagService;
    }

    @GetMapping
    public ResponseEntity<List<Tag>>
    getAllTags() {

        return ResponseEntity.ok(
                tagService.getAllTags()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tag>
    getTagById(
            @PathVariable UUID id
    ) {

        return ResponseEntity.ok(
                tagService.getTagById(id)
        );
    }

    @PostMapping
    public ResponseEntity<Tag>
    createTag(
            @RequestBody Tag tag
    ) {

        return ResponseEntity.ok(
                tagService.createTag(tag)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tag>
    updateTag(
            @PathVariable UUID id,
            @RequestBody Tag tag
    ) {

        return ResponseEntity.ok(
                tagService.updateTag(
                        id,
                        tag
                )
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String>
    deleteTag(
            @PathVariable UUID id
    ) {

        tagService.deleteTag(id);

        return ResponseEntity.ok(
                "Tag deleted successfully"
        );
    }
}