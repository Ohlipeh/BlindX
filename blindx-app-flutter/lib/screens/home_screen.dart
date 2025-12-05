import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../main.dart';
import '../services/gemini_service.dart';
import '../widgets/blind_button.dart'; // <--- Importamos o botão aqui

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;
  final GeminiService _geminiService = GeminiService();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isProcessing = false;
  String _statusMessage = "Toque para identificar";

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTts();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      setState(() => _statusMessage = "Nenhuma câmera encontrada");
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      _speak("Erro ao abrir a câmera");
    }
  }

  void _initTts() async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    _speak("Blind X Vision pronto.");
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _analyzeScene() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        // ignore: curly_braces_in_flow_control_structures
        _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "Analisando...";
    });

    HapticFeedback.mediumImpact();
    _speak("Olhando...");

    try {
      final XFile image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();
      final description = await _geminiService.analyzeImage(imageBytes);

      setState(() {
        _statusMessage = description;
      });
      HapticFeedback.heavyImpact();
      _speak(description);
    } catch (e) {
      _speak("Erro na análise.");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Colors.yellowAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // CÂMERA
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

            // RESULTADO
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
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),

            // BOTÃO REUTILIZÁVEL (Agora usando o widget separado)
            Expanded(
              flex: 1,
              child: BlindButton(
                label: "O QUE É ISSO?",
                hint: "Toque duas vezes para descrever o ambiente",
                isLoading: _isProcessing,
                onTap: _analyzeScene,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
