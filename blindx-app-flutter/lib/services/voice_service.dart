import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Serviço responsável por gerenciar o feedback de voz e tátil do aplicativo.
class VoiceService {
  /// Executa o comando de falar e vibrar o dispositivo.
  ///
  /// [context] é usado para mostrar o SnackBar visual (simulação).
  /// [text] é a frase que será dita ao usuário.
  static void speak(BuildContext context, String text) {
    // 1. Feedback Tátil (Haptic):
    // Essencial para cegos confirmarem que a ação foi registrada.
    HapticFeedback.mediumImpact();

    // 2. Feedback Visual (Simulação):
    // Mostra na tela o que estaria sendo falado pelo TTS.
    // Útil para desenvolvedores videntes testarem sem som.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.yellowAccent, // Alto contraste no feedback
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.record_voice_over, color: Colors.black, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "Falando: \"$text\"",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
