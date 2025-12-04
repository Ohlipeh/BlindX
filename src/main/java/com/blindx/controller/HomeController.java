package com.blindx.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    // Quando acessar "localhost:8080", o Java entrega o arquivo index.html
    @GetMapping("/")
    public String home() {
        return "index.html"; // O Spring procura isso automaticamente na pasta static
    }
    
    // Esse é um exemplo de como seria o BACKEND REAL (Para mostrar aos jurados)
    // No futuro, o JavaScript chamaria essa função aqui em vez de chamar o Google direto
    /*
    @PostMapping("/api/descrever")
    public ResponseEntity<String> descreverImagem(@RequestBody String imagemBase64) {
        // 1. Recebe a imagem
        // 2. Chama o Gemini pelo Java (Segurança da API Key)
        // 3. Retorna o texto
        return ResponseEntity.ok("Descrição gerada pelo Java...");
    }
    */
}