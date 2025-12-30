package com.healthmall.util;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;

public class JsonToStringDeserializer extends JsonDeserializer<String> {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        JsonNode node = p.getCodec().readTree(p);
        
        if (node.isObject() || node.isArray()) {
            return objectMapper.writeValueAsString(node);
        }
        
        return node.asText();
    }
}
