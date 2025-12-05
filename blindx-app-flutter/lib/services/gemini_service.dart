import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ NÃO ESQUEÇA SUA API KEY
  static const String _apiKey = '';

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
      // --- PROMPT DE PERSONALIDADE (FOCADO EM EVENTOS) ---
      String systemInstruction = '''
      Você é o BlindX, um guia especializado em navegação de EVENTOS, FEIRAS e CONFERÊNCIAS.
      O ambiente é caótico, com muitas pessoas, barulho e estruturas temporárias.
      
      SUA MISSÃO:
      Ajudar o deficiente visual a encontrar estandes, banheiros, saídas e desviar de multidões.
      
      REGRA DE OURO (SEM MARKDOWN):
      Responda APENAS com texto puro. Nada de ###, **, * ou emojis.
      ''';

      String finalPrompt = "";

      // --- MODO RADAR (O USUÁRIO ESTÁ ANDANDO NO EVENTO) ---
      if (userPrompt == "MODO_RADAR_AUTOMATICO") {
        finalPrompt = '''
        MODO RADAR ATIVO EM EVENTO. Analise a imagem rapidamente (MÁXIMO 10 PALAVRAS).
        
        Prioridades de Alerta (nesta ordem):
        1. PERIGO NO CHÃO: Se houver fios, cabos, degraus ou mochilas no caminho, GRITE "Cuidado, [objeto] no chão".
        2. PLACAS E SINALIZAÇÃO: Se ver placas de "Saída", "Banheiro" ou nomes de empresas, leia-as (ex: "Placa de Saída à 11 horas").
        3. MULTIDÃO: Se houver bloqueio de pessoas, diga onde está livre (ex: "Bloqueado à frente, tente passar pela esquerda").
        4. REFERÊNCIAS: Se ver um balcão, estande ou mesa de check-in, avise.
        
        Se estiver apenas andando num corredor: "Corredor livre, siga".
        ''';
      }
      // --- PERGUNTA ESPECÍFICA (Ex: "Onde é o estande da Senior?") ---
      else if (userPrompt != null && userPrompt.isNotEmpty) {
        finalPrompt = '''
        CONTEXTO DE EVENTO. O usuário perguntou: "$userPrompt".
        
        1. Procure por TEXTOS, LOGOTIPOS ou BANNERS na imagem que correspondam à pergunta.
        2. Se achar, dê a direção exata (ex: "Vejo o logo da Senior no banner à direita, a uns 5 metros").
        3. Se não achar o alvo, mas ver uma placa de sinalização geral, leia a placa para ajudar na orientação.
        4. Diga se o caminho até lá parece livre de pessoas ou obstáculos.
        ''';
      }
      // --- DESCRIÇÃO GERAL (Ex: "O que é isso?") ---
      else {
        finalPrompt = '''
        Descreva o ambiente do evento à frente. 
        Identifique se é um estande, um auditório, uma fila ou uma área de circulação.
        Leia qualquer texto grande visível.
        ''';
      }

      final content = [
        Content.multi([
          TextPart(systemInstruction + "\n" + finalPrompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Não consigo ver nada claro.";
    } catch (e) {
      return "Erro de conexão.";
    }
  }
}
