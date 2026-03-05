package com.healthmall.dto;

import java.util.List;

public class UpdateTagsRequest {
    private List<String> tags;

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }
}
