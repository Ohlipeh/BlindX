import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart'; // Para Haptics

class VoiceService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  /// Inicializa os serviços de voz (TTS e STT)
  static Future<void> init() async {
    if (!_isInitialized) {
      try {
        await _speech.initialize(
          onError: (val) => debugPrint('Erro STT: $val'),
          onStatus: (val) => debugPrint('Status STT: $val'),
        );

        await _flutterTts.setLanguage("pt-BR");
        await _flutterTts
            .setSpeechRate(0.5); // Velocidade confortável para cegos
        _isInitialized = true;
      } catch (e) {
        debugPrint("Erro ao inicializar voz: $e");
      }
    }
  }

  /// Fala o texto (Feedback auditivo + Tátil) com LIMPEZA DE MARKDOWN
  static Future<void> speak(String text) async {
    if (!_isInitialized) await init();

    // --- LIMPEZA ANTI-HASHTAG ---
    // Remove caracteres especiais do Markdown antes de enviar para a voz
    final String cleanText = text
        .replaceAll(
            RegExp(r'[#*_`\[\]<>]'), '') // Remove #, *, _, `, [, ], <, >
        .replaceAll(RegExp(r'\s+'), ' ') // Remove espaços duplos
        .trim();

    HapticFeedback.lightImpact(); // Feedback tátil leve
    await _flutterTts.speak(cleanText);
  }

  /// Escuta o usuário com configurações anti-erro (no_match)
  static Future<void> listen({
    required Function(String) onResult,
    required VoidCallback onListeningStart,
    required VoidCallback onListeningEnd,
  }) async {
    if (!_isInitialized) await init();

    if (_speech.isAvailable) {
      // Pequeno delay para garantir que o TTS anterior parou de falar
      await Future.delayed(const Duration(milliseconds: 500));

      onListeningStart();

      await _speech.listen(
        onResult: (val) {
          // Só retorna se for o resultado final para evitar processamento picotado
          if (val.finalResult) {
            onListeningEnd();
            onResult(val.recognizedWords);
          }
        },
        // CONFIGURAÇÕES CRÍTICAS PARA CEGOS:
        listenFor: const Duration(seconds: 30), // Tempo total máximo de escuta
        pauseFor:
            const Duration(seconds: 4), // Espera 4s de silêncio (evita corte)
        partialResults: false, // Espera a frase completa
        cancelOnError: false,
        listenMode: stt.ListenMode.search,
        localeId: "pt_BR",
      );
    } else {
      debugPrint("Reconhecimento de voz não disponível");
      speak("Erro no microfone.");
      onListeningEnd();
    }
  }

  static Future<void> stop() async {
    await _speech.stop();
    await _flutterTts.stop();
  }
}
