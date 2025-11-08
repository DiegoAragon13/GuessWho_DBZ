import 'package:bandersnatch/music_manager.dart';
import 'package:bandersnatch/pages/splash.dart';
import 'package:flutter/material.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ==================== MODELO DE DATOS ====================
class Personaje {
  final String nombre;
  final List<String> caracteristicas;
  bool isEliminado;

  Personaje({
    required this.nombre,
    required this.caracteristicas,
    this.isEliminado = false,
  });

  factory Personaje.fromJson(Map<String, dynamic> json) {
    return Personaje(
      nombre: json['nombre'],
      caracteristicas: List<String>.from(json['caracteristicas']),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final MusicManager _musicManager = MusicManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Iniciar música después de que la app esté lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _musicManager.playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausar música cuando la app va al fondo
    if (state == AppLifecycleState.paused) {
      _musicManager.pauseMusic();
    }
    // Reanudar música cuando la app vuelve al frente
    else if (state == AppLifecycleState.resumed) {
      _musicManager.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dragon Ball - Adivina Quién',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DragonBallSplash(),
    );
  }
}