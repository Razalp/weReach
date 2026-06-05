import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// Start playing the alarm sound in a loop
  Future<void> playAlarm(String soundName) async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      
      // Configure looping
      await _player.setLoopMode(LoopMode.one);
      
      // Load and play sound based on selection
      if (soundName == "default" || soundName.isEmpty) {
        // Try to load standard asset, fallback to system sound if not compiled
        try {
          await _player.setAsset('assets/alarm.mp3');
        } catch (e) {
          // Fallback url or system alert sound simulation
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse("asset:///assets/alarm.mp3")),
          );
        }
      } else {
        // In a real app, map other sound strings to respective files
        try {
          await _player.setAsset('assets/$soundName.mp3');
        } catch (_) {
          await _player.setAsset('assets/alarm.mp3');
        }
      }

      await _player.play();
    } catch (e) {
      // If asset load fails completely, we can trigger a system beep using services channel
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Stop playing the alarm
  Future<void> stopAlarm() async {
    _isPlaying = false;
    await _player.stop();
  }

  /// Single trigger for tactile feedback / sound test
  Future<void> testBeep() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
