package com.blindx.controller;

import com.blindx.service.GeminiService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class GeminiController {

    private final GeminiService geminiService;

    public GeminiController(GeminiService geminiService) {
        this.geminiService = geminiService;
    }

    @PostMapping("/describe")
    public Mono<ResponseEntity<Map<String, String>>> describeImage(@RequestBody Map<String, String> request) {
        String base64Image = request.get("image");
        
        if (base64Image == null || base64Image.isEmpty()) {
            return Mono.just(ResponseEntity.badRequest()
                    .body(Map.of("error", "Imagem não fornecida")));
        }

        // Remove o prefixo data:image/jpeg;base64, se existir
        if (base64Image.contains(",")) {
            base64Image = base64Image.split(",")[1];
        }

        return geminiService.describeImage(base64Image)
                .map(description -> ResponseEntity.ok(Map.of("description", description)))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError()
                        .body(Map.of("error", e.getMessage()))));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}
