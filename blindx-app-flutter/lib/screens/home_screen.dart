import 'dart:async'; // Importante para o Timer
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import '../widgets/blind_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;
  final GeminiService _geminiService = GeminiService();

  // Variáveis do Radar
  Timer? _radarTimer;
  bool _isRadarActive = false;

  bool _isProcessing = false;
  String _statusMessage = "Toque para perguntar\nSegure para Radar";

  @override
  void initState() {
    super.initState();
    _initCamera();
    VoiceService.init();
    _initialWelcome();
  }

  void _initialWelcome() async {
    await Future.delayed(const Duration(seconds: 1));
    VoiceService.speak("Blind X pronto.");
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.medium,
        enableAudio: false);
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("Erro câmera: $e");
    }
  }

  // --- LÓGICA DO MODO RADAR (NOVO) ---
  void _toggleRadarMode() {
    setState(() {
      _isRadarActive = !_isRadarActive;
    });

    if (_isRadarActive) {
      VoiceService.speak("Modo Radar Ativado. Caminhe devagar.");
      // Inicia o loop a cada 6 segundos
      _radarTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (!_isProcessing &&
            _controller != null &&
            _controller!.value.isInitialized) {
          // Passamos uma flag especial para o Gemini saber que é radar
          _captureAndAnalyze("MODO_RADAR_AUTOMATICO");
        }
      });
    } else {
      VoiceService.speak("Modo Radar Parado.");
      _radarTimer?.cancel();
      _radarTimer = null;
    }
  }

  // --- LÓGICA DE INTERAÇÃO MANUAL ---
  Future<void> _startInteraction() async {
    // Se o usuário vai falar, pausamos o radar momentaneamente para não misturar vozes
    _radarTimer?.cancel();

    if (_isProcessing) return;

    HapticFeedback.heavyImpact();
    await VoiceService.speak("Pode falar...");

    await VoiceService.listen(
      onListeningStart: () => setState(() => _statusMessage = "Ouvindo..."),
      onListeningEnd: () => setState(() => _statusMessage = "Processando..."),
      onResult: (command) {
        _captureAndAnalyze(command);
        // Se o radar estava ativo antes, reiniciar ele após a resposta (opcional)
        if (_isRadarActive) _toggleRadarMode();
      },
    );
  }

  Future<void> _captureAndAnalyze(String command) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = command == "MODO_RADAR_AUTOMATICO"
          ? "Radar: Escaneando..."
          : "Analisando: $command";
    });

    // --- NOVO FEEDBACK SONORO (O "BIP") ---
    // Faz o barulho de "Click" do Android (sem precisar de arquivos mp3)
    await SystemSound.play(SystemSoundType.click);

    if (command == "MODO_RADAR_AUTOMATICO") {
      // No Radar: Apenas vibração leve para não irritar
      HapticFeedback.lightImpact();
    } else {
      // No Manual: Vibração forte + Fala para preencher o silêncio
      HapticFeedback.mediumImpact();
      // Não usamos 'await' aqui para ele falar ENQUANTO tira a foto
      VoiceService.speak("Processando...");
    }

    try {
      final XFile image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      final description =
          await _geminiService.analyzeImage(imageBytes, userPrompt: command);

      setState(() => _statusMessage = description);
      await VoiceService.speak(description);
    } catch (e) {
      if (command != "MODO_RADAR_AUTOMATICO") {
        VoiceService.speak("Erro na análise.");
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _radarTimer?.cancel(); // Importante cancelar o timer ao sair
    _controller?.dispose();
    VoiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          // Borda fica VERDE se o radar estiver ligado
                          color: _isRadarActive
                              ? Colors.greenAccent
                              : Colors.yellowAccent,
                          width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  if (_isRadarActive)
                    const Positioned(
                      top: 30,
                      right: 30,
                      child: Icon(Icons.radar,
                          color: Colors.greenAccent, size: 50),
                    )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _statusMessage,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: BlindButton(
                // Muda o texto do botão dependendo do estado
                label: _isRadarActive ? "PARAR RADAR" : "FALAR",
                hint: "Toque para falar, segure para radar",
                backgroundColor:
                    _isRadarActive ? Colors.greenAccent : Colors.yellowAccent,
                isLoading: _isProcessing,
                onTap: _isRadarActive
                    ? _toggleRadarMode
                    : _startInteraction, // Se radar ativo, toque simples para
                onLongPress: _toggleRadarMode, // Segurar ativa/desativa radar
              ),
            ),
          ],
        ),
      ),
    );
  }
}
