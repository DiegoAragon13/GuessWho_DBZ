import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Gestor de audio para música de fondo
/// Compatible con Web y Móvil
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  double _musicVolume = 0.5;
  bool _isInitialized = false;
  String? _currentAssetPath;

  /// Inicializar el sistema de audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      _isInitialized = true;
      print('AudioManager inicializado correctamente');
    } catch (e) {
      print('Error inicializando audio: $e');
    }
  }

  /// Reproducir música de fondo en loop
  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_isMusicEnabled || !_isInitialized) return;

    try {
      await _musicPlayer.stop();
      _currentAssetPath = assetPath;

      if (kIsWeb) {
        // En Web, usar la URL del asset directamente
        // Los assets en web están en /assets/
        final webPath = 'assets/$assetPath';
        print('Reproduciendo música (Web): $webPath');
        await _musicPlayer.play(UrlSource(webPath));
      } else {
        // En móvil, usar AssetSource
        print('Reproduciendo música (Móvil): $assetPath');
        await _musicPlayer.play(AssetSource(assetPath));
      }

      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      // En Web, el navegador bloquea autoplay hasta interacción del usuario
      if (e.toString().contains('NotAllowedError')) {
        print('⚠️ Autoplay bloqueado. La música se reproducirá tras la primera interacción.');
      } else {
        print('Error reproduciendo música: $e');
      }
      // No lanzar error, solo continuar sin música
    }
  }

  /// Detener música de fondo
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Error deteniendo música: $e');
    }
  }

  /// Pausar música
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Error pausando música: $e');
    }
  }

  /// Reanudar música
  Future<void> resumeMusic() async {
    if (!_isMusicEnabled) return;

    try {
      // Si el player está paused, reanudar
      final state = _musicPlayer.state;
      if (state == PlayerState.paused) {
        await _musicPlayer.resume();
      } else if (state == PlayerState.stopped && _currentAssetPath != null) {
        // Si está stopped, reproducir de nuevo
        await playBackgroundMusic(_currentAssetPath!);
      }
    } catch (e) {
      print('Error reanudando música: $e');
    }
  }

  /// Activar/desactivar música
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      await pauseMusic();
    } else {
      await resumeMusic();
    }
  }

  /// Cambiar volumen de música (0.0 a 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      print('Error cambiando volumen: $e');
    }
  }

  /// Obtener estado de música
  bool get isMusicEnabled => _isMusicEnabled;

  /// Obtener volumen actual de música
  double get musicVolume => _musicVolume;

  /// Limpiar recursos
  Future<void> dispose() async {
    try {
      await _musicPlayer.dispose();
    } catch (e) {
      print('Error liberando recursos de audio: $e');
    }
  }
}