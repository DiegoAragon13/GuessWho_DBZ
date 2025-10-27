import 'package:flutter_tts/flutter_tts.dart';

/// Gestor de narración de texto
/// Lee en voz alta el texto del Narrador usando Text-to-Speech
class NarratorSpeechManager {
  static final NarratorSpeechManager _instance = NarratorSpeechManager._internal();
  factory NarratorSpeechManager() => _instance;
  NarratorSpeechManager._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isEnabled = true;
  bool _isSpeaking = false;
  double _volume = 0.8;
  double _pitch = 1.0;
  double _rate = 0.5; // Velocidad de lectura (0.0 - 1.0)

  /// Inicializar Text-to-Speech
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar idioma español
      await _flutterTts.setLanguage("es-MX");

      // Configurar parámetros de voz
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);

      // Callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        print('Narración iniciada');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        print('Narración completada');
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        print('Error en narración: $message');
      });

      _isInitialized = true;
      print('NarratorSpeechManager inicializado');
    } catch (e) {
      print('Error inicializando TTS: $e');
    }
  }

  /// Narrar texto (solo si es del Narrador)
  Future<void> speak(String text, String characterName) async {
    // Solo narrar si es el Narrador y está habilitado
    if (!_isEnabled || !_isInitialized || characterName != 'Narrador') {
      return;
    }

    // Si ya está hablando, detener primero
    if (_isSpeaking) {
      await stop();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error al narrar: $e');
    }
  }

  /// Detener narración
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error al detener narración: $e');
    }
  }

  /// Pausar narración
  Future<void> pause() async {
    if (!_isInitialized || !_isSpeaking) return;

    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error al pausar: $e');
    }
  }

  /// Activar/desactivar narración
  Future<void> toggle() async {
    _isEnabled = !_isEnabled;
    if (!_isEnabled && _isSpeaking) {
      await stop();
    }
  }

  /// Cambiar velocidad de lectura (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    _rate = rate.clamp(0.0, 1.0);
    try {
      await _flutterTts.setSpeechRate(_rate);
    } catch (e) {
      print('Error cambiando velocidad: $e');
    }
  }

  /// Cambiar volumen (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _flutterTts.setVolume(_volume);
    } catch (e) {
      print('Error cambiando volumen: $e');
    }
  }

  /// Cambiar tono de voz (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    try {
      await _flutterTts.setPitch(_pitch);
    } catch (e) {
      print('Error cambiando tono: $e');
    }
  }

  /// Obtener voces disponibles
  Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) return [];

    try {
      return await _flutterTts.getVoices ?? [];
    } catch (e) {
      print('Error obteniendo voces: $e');
      return [];
    }
  }

  /// Establecer voz específica
  Future<void> setVoice(Map<String, String> voice) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      print('Error estableciendo voz: $e');
    }
  }

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;

  Future<void> dispose() async {
    if (_isSpeaking) {
      await stop();
    }
  }
}