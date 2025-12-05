import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

// Variável global para acessar as câmeras em qualquer lugar
late List<CameraDescription> cameras;

Future<void> main() async {
  // Garante que o plugin da câmera e outros serviços nativos inicializem
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Busca as câmeras disponíveis no dispositivo
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Erro na câmera: $e');
    cameras = []; // Inicia vazio se der erro
  }

  runApp(const BlindXApp());
}

class BlindXApp extends StatelessWidget {
  const BlindXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlindX Vision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            Colors.black, // Fundo preto (Economia + Contraste)
        primaryColor: Colors.yellowAccent, // Amarelo (Destaque visual)
        colorScheme: const ColorScheme.dark(
          primary: Colors.yellowAccent,
          surface: Colors.black,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
