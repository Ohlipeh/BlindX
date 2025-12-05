package com.blindx.controller;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Map;

@Service
public class GeminiService {

    // ⚠️ SUBSTITUA PELA SUA CHAVE API NOVA
    private static final String API_KEY = "SUA_NOVA_API_KEY_AQUI";
    private static final String GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + API_KEY;

    private final WebClient webClient;

    public GeminiService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl(GEMINI_URL).build();
    }

    public Mono<String> describeImage(String base64Image) {
        // Monta o JSON (Payload) para a API do Google
        // Estrutura: contents -> parts -> [text, inline_data]
        
        Map<String, Object> payload = Map.of(
            "contents", List.of(
                Map.of(
                    "parts", List.of(
                        Map.of("text", "Descreva esta imagem para um cego em português. Seja breve e útil."),
                        Map.of("inline_data", Map.of(
                            "mime_type", "image/jpeg",
                            "data", base64Image
                        ))
                    )
                )
            )
        );

        return webClient.post()
                .bodyValue(payload)
                .retrieve()
                .bodyToMono(Map.class)
                .map(this::extractTextFromResponse)
                .onErrorResume(e -> {
                    System.err.println("Erro na API Gemini: " + e.getMessage());
                    return Mono.just("Erro ao processar imagem com IA.");
                });
    }

    // Helper para extrair o texto do JSON complexo do Google
    private String extractTextFromResponse(Map response) {
        try {
            List candidates = (List) response.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map firstCandidate = (Map) candidates.get(0);
                Map content = (Map) firstCandidate.get("content");
                List parts = (List) content.get("parts");
                Map firstPart = (Map) parts.get(0);
                return (String) firstPart.get("text");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Não consegui identificar nada.";
    }
}