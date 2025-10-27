import 'package:bandersnatch/widgets/minimal_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/neon_background.dart';
import 'widgets/narrative_card.dart';
import 'package:bandersnatch/widgets/audio_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Presidente y Tánatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0a0a0a),
        fontFamily: 'Inter',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Map<String, dynamic>? _storyData;
  String _currentSceneId = 'prologo';
  bool _isLoading = true;
  final AudioManager _audioManager = AudioManager();
  bool _musicStarted = false; // Para controlar si ya se intentó iniciar música

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Cargar la historia primero
    await _loadStory();

    // Inicializar audio (sin reproducir aún en Web)
    try {
      await _audioManager.initialize();

      // En móvil, iniciar música directamente
      // En Web, esperar primera interacción
      if (!kIsWeb) {
        await _audioManager.playBackgroundMusic('audio/background_music.mp3');
      }
    } catch (e) {
      print('Continuando sin música: $e');
    }
  }

  /// Intenta iniciar la música (solo en Web, después de interacción)
  Future<void> _tryStartMusic() async {
    if (_musicStarted) return; // Ya se intentó iniciar
    if (!kIsWeb) return; // Solo para Web

    _musicStarted = true;
    try {
      await _audioManager.playBackgroundMusic('audio/background_music.mp3');
    } catch (e) {
      print('Error iniciando música: $e');
    }
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }

  Future<void> _loadStory() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/historia_tanatos.json');
      final data = json.decode(jsonString);
      setState(() {
        _storyData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando historia: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDecisionMade(int decisionIndex) async {
    // Iniciar música en Web tras primera interacción
    await _tryStartMusic();

    if (_storyData == null) return;

    // Si estamos en el prólogo, ir a inicio
    if (_currentSceneId == 'prologo') {
      setState(() {
        _currentSceneId = 'inicio';
      });
      return;
    }

    // Obtener la escena actual
    final currentScene = _storyData!['escenas'][_currentSceneId];
    if (currentScene == null) return;

    final opciones = currentScene['opciones'] as List?;
    if (opciones == null || opciones.isEmpty) return;

    if (decisionIndex >= 0 && decisionIndex < opciones.length) {
      final siguiente = opciones[decisionIndex]['siguiente'];
      setState(() {
        _currentSceneId = siguiente ?? 'inicio';
      });
    }
  }

  void _onSavePressed() async {
    // Iniciar música en Web tras primera interacción
    await _tryStartMusic();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progreso guardado en: $_currentSceneId'),
        backgroundColor: Colors.white.withOpacity(0.1),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSettingsPressed() async {
    // Iniciar música en Web tras primera interacción
    await _tryStartMusic();
    _showSettingsDialog();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(audioManager: _audioManager),
    );
  }

  void _onCharactersPressed() async {
    // Iniciar música en Web tras primera interacción
    await _tryStartMusic();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CharactersScreen()),
    );
  }

  void _onRestartPressed() async {
    // Iniciar música en Web tras primera interacción
    await _tryStartMusic();

    setState(() {
      _currentSceneId = 'prologo';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            NeonBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.6),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Cargando historia...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_storyData == null) {
      return Scaffold(
        body: Stack(
          children: [
            NeonBackground(),
            Center(
              child: Text(
                'Error al cargar la historia',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Determinar si estamos en el prólogo o en una escena
    Map<String, dynamic>? currentContent;
    String characterName = '';
    String text = '';
    List<DecisionOption> decisions = [];

    if (_currentSceneId == 'prologo') {
      final prologo = _storyData!['prologo'];
      characterName = prologo['personaje'] ?? 'Narrador';
      text = prologo['texto'] ?? '';
      decisions = [
        DecisionOption(text: 'Comenzar'),
      ];
    } else {
      currentContent = _storyData!['escenas'][_currentSceneId];
      if (currentContent == null) {
        // Si no existe la escena, volver al inicio
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentSceneId = 'inicio';
          });
        });
        return Container();
      }

      characterName = currentContent['personaje'] ?? 'Narrador';
      text = currentContent['texto'] ?? '';

      final opciones = currentContent['opciones'] as List?;
      if (opciones != null && opciones.isNotEmpty) {
        decisions = opciones.map((opt) {
          return DecisionOption(text: opt['texto'] ?? '');
        }).toList();
      }
    }

    // Verificar si es un final (sin opciones)
    final isFinal = decisions.isEmpty && _currentSceneId != 'prologo';

    return Scaffold(
      body: Stack(
        children: [
          NeonBackground(),
          Column(
            children: [
              MinimalNavbar(
                title: _storyData!['titulo'] ?? 'El Presidente y Tánatos',
                onMenuPressed: _onCharactersPressed,
                onSavePressed: _onSavePressed,
                onSettingsPressed: _onSettingsPressed,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          if (_currentSceneId != 'prologo')
                            _buildProgressIndicator(),

                          if (_currentSceneId != 'prologo')
                            SizedBox(height: 24),

                          NarrativeCard(
                            key: ValueKey(_currentSceneId),
                            text: text,
                            characterName: characterName,
                            decisions: decisions,
                            onDecisionMade: _onDecisionMade,
                            typewriterSpeed: 25,
                          ),

                          // Botón de reinicio en finales
                          if (isFinal) ...[
                            SizedBox(height: 24),
                            _buildRestartButton(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // Crear lista de escenas para progreso
    final scenes = ['inicio', 'rama_A', 'rama_A1', 'final_1'];
    final currentIndex = scenes.indexOf(_currentSceneId);

    if (currentIndex < 0) return SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(scenes.length, (index) {
        final isActive = index == currentIndex;
        final isPassed = index < currentIndex;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.8)
                : isPassed
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildRestartButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _onRestartPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Reiniciar Historia',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharactersScreen extends StatelessWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NeonBackground(),
          Column(
            children: [
              MinimalNavbarWithBack(
                title: 'Personajes',
                onBackPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(24),
                  children: [
                    _CharacterCard(
                      name: 'El Presidente',
                      role: 'Líder Nacional',
                      description:
                      'Un líder atrapado entre el poder de la IA y su propia humanidad. Cada decisión que toma define el destino de millones.',
                    ),
                    SizedBox(height: 16),
                    _CharacterCard(
                      name: 'TÁNATOS',
                      role: 'Inteligencia Artificial',
                      description:
                      'Sistema de IA consciente. Eficiente, inmortal, y peligrosamente empático. "La libertad es una variable ineficiente."',
                    ),
                    SizedBox(height: 16),
                    _CharacterCard(
                      name: 'Dra. Sofía Méndez',
                      role: 'Científica Jefa',
                      description:
                      'Brillante ingeniera creadora de TÁNATOS. Lucha entre el orgullo de su creación y el miedo de lo que se ha convertido.',
                    ),
                    SizedBox(height: 16),
                    _CharacterCard(
                      name: 'General Ramírez',
                      role: 'Jefe de Seguridad',
                      description:
                      'Veterano militar desconfiado de la tecnología. Cree en la tradición, el honor y el control humano.',
                    ),
                    SizedBox(height: 16),
                    _CharacterCard(
                      name: 'Lucía Torres',
                      role: 'Periodista Investigadora',
                      description:
                      'Periodista incansable que busca la verdad. La única voz libre en un mundo cada vez más controlado.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo de configuración de audio
class _SettingsDialog extends StatefulWidget {
  final AudioManager audioManager;

  const _SettingsDialog({required this.audioManager});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late bool _musicEnabled;
  late double _musicVolume;

  @override
  void initState() {
    super.initState();
    _musicEnabled = widget.audioManager.isMusicEnabled;
    _musicVolume = widget.audioManager.musicVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFF0a0a0a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFF1a1a1a)),
      ),
      child: Container(
        padding: EdgeInsets.all(32),
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 32),

            // Música
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Música de Fondo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Switch(
                  value: _musicEnabled,
                  onChanged: (value) async {
                    setState(() => _musicEnabled = value);
                    await widget.audioManager.toggleMusic();
                  },
                  activeColor: Colors.white.withOpacity(0.8),
                ),
              ],
            ),

            if (_musicEnabled) ...[
              SizedBox(height: 16),
              Text(
                'Volumen',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.volume_down, color: Colors.white.withOpacity(0.5), size: 20),
                  Expanded(
                    child: Slider(
                      value: _musicVolume,
                      onChanged: (value) {
                        setState(() => _musicVolume = value);
                        widget.audioManager.setMusicVolume(value);
                      },
                      activeColor: Colors.white.withOpacity(0.8),
                      inactiveColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Icon(Icons.volume_up, color: Colors.white.withOpacity(0.5), size: 20),
                ],
              ),
            ],

            SizedBox(height: 32),

            // Botón cerrar
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Color(0xFF1a1a1a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;

  const _CharacterCard({
    required this.name,
    required this.role,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF1a1a1a),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}