import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/voice_service.dart';

class AudioDescriptionScreen extends StatefulWidget {
  const AudioDescriptionScreen({super.key});

  @override
  State<AudioDescriptionScreen> createState() => _AudioDescriptionScreenState();
}

class _AudioDescriptionScreenState extends State<AudioDescriptionScreen> {
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    // Anuncia a tela assim que ela é montada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoiceService.speak(
        context,
        "Tela de Audiodescrição aberta. Toque no centro para ativar.",
      );
    });
  }

  void _toggleAudioDescription() {
    HapticFeedback.heavyImpact();
    setState(() {
      isActive = !isActive;
    });

    // Lógica simulada de descrição de ambiente
    if (isActive) {
      VoiceService.speak(
        context,
        "Audiodescrição Ativada. À sua frente há um stand de tecnologia com três pessoas conversando. O chão é acarpetado.",
      );
    } else {
      VoiceService.speak(context, "Audiodescrição Pausada.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellowAccent),
        title: const Text(
          "Audiodescrição",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // Botão gigante que ocupa quase toda a tela
            child: Semantics(
              label: isActive
                  ? "Audiodescrição Ativa. Toque para pausar."
                  : "Audiodescrição Pausada. Toque para ativar.",
              button: true,
              child: GestureDetector(
                onTap: _toggleAudioDescription,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.greenAccent : Colors.grey[900],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isActive ? Colors.green : Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? Icons.volume_up : Icons.volume_off,
                        size: 100,
                        color: isActive ? Colors.black : Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isActive ? "OUVINDO..." : "TOCAR PARA OUVIR",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Área de controles inferiores (Velocidade)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.yellowAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    size: 40,
                    color: Colors.black,
                  ),
                  onPressed: () => VoiceService.speak(
                    context,
                    "Diminuindo velocidade da voz",
                  ),
                  tooltip: "Mais lento",
                ),
                const Text(
                  "VELOCIDADE",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    size: 40,
                    color: Colors.black,
                  ),
                  onPressed: () => VoiceService.speak(
                    context,
                    "Aumentando velocidade da voz",
                  ),
                  tooltip: "Mais rápido",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
