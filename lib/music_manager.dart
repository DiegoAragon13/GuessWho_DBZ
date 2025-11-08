// music_manager.dart
import 'package:audioplayers/audioplayers.dart';

class MusicManager {
  static final MusicManager _instance = MusicManager._internal();
  factory MusicManager() => _instance;
  MusicManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Repetir en bucle
      await _audioPlayer.setVolume(0.5); // Volumen al 50%
      await _audioPlayer.play(AssetSource('music/musica.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error al reproducir música: $e');
    }
  }

  Future<void> pauseMusic() async {
    if (!_isPlaying) return;
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> resumeMusic() async {
    if (_isPlaying) return;
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    // volume debe estar entre 0.0 y 1.0
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}