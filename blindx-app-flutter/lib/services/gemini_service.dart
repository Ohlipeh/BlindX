import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ COLOQUE SUA API KEY AQUI:
  static const String _apiKey = 'AIzaSyCMdQBHfJH4_WcYbsVOWwMjdVEqeeFVKvo';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> analyzeImage(Uint8List imageBytes,
      {String? userPrompt}) async {
    try {
      // PROMPT DO SISTEMA
      // Define a personalidade e as regras de formatação (SEM MARKDOWN)
      String systemInstruction = '''
      Você é o BlindX, um assistente para deficientes visuais.
      
      REGRA DE OURO DE FORMATAÇÃO:
      - Responda APENAS com texto puro. 
      - JAMAIS use formatação Markdown (como ###, **, *, -). 
      - Não use emojis.
      
      Seu objetivo é guiar o usuário.
      ''';

      String finalPrompt = "";

      // LÓGICA DO MODO RADAR (Respostas ultra-rápidas)
      if (userPrompt == "MODO_RADAR_AUTOMATICO") {
        finalPrompt = '''
        MODO RADAR (Usuário em movimento).
        Analise a imagem e responda em MÁXIMO 5 PALAVRAS.
        - Se caminho livre: "Livre".
        - Se obstáculo: "Cuidado, [nome do objeto] à frente".
        - Se direção: "Porta à direita", "Corredor à esquerda".
        Seja imediato. Sem Markdown.
        ''';
      }
      // LÓGICA DE PERGUNTA ESPECÍFICA (Ex: "Onde fica o banheiro?")
      else if (userPrompt != null && userPrompt.isNotEmpty) {
        finalPrompt = '''
        O usuário perguntou: "$userPrompt".
        Responda especificamente a isso. Use referências de relógio (ex: às 3 horas) ou lados (esquerda/direita).
        Sem Markdown.
        ''';
      }
      // LÓGICA PADRÃO (Descrição geral)
      else {
        finalPrompt = "Descreva brevemente o que está à frente. Sem Markdown.";
      }

      final content = [
        Content.multi([
          TextPart(systemInstruction + "\n" + finalPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Não identifiquei nada.";
    } catch (e) {
      return "Erro de conexão.";
    }
  }
}
