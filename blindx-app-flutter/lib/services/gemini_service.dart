import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ GERE SUA CHAVE EM: https://aistudio.google.com/app/apikey
  // E COLE ABAIXO DENTRO DAS ASPAS:
  static const String _apiKey = 'AIzaSyBsM0lNCjy_Yx4bY-Vnzhd3y9tbVgt-9Lc';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Modelo rápido para visão
      apiKey: _apiKey,
    );
  }

  Future<String> analyzeImage(Uint8List imageBytes) async {
    try {
      final content = [
        Content.multi([
          TextPart(
              'Descreva esta imagem para uma pessoa cega em português. Seja breve, direto e útil para navegação ou reconhecimento de objetos. Comece dizendo o que é mais importante.'),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Não consegui identificar nada na imagem.";
    } catch (e) {
      return "Erro ao conectar com a inteligência artificial. Verifique sua internet.";
    }
  }
}
