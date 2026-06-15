import 'package:just_audio/just_audio.dart';
import 'package:contrast_coach/core/constants/app_assets.dart';

class AudioCueService {
  AudioCueService();
  final AudioPlayer _player = AudioPlayer();

  Future<void> playPhaseTransition() async {
    try {
      await _player.setAsset(AppAssets.audioPhaseTransition);
      await _player.play();
    } catch (_) {
      // Audio is best-effort; don't crash session on failure
    }
  }

  Future<void> playSessionStart() async {
    try {
      await _player.setAsset(AppAssets.audioSessionStart);
      await _player.play();
    } catch (_) {}
  }

  Future<void> playSessionComplete() async {
    try {
      await _player.setAsset(AppAssets.audioSessionComplete);
      await _player.play();
    } catch (_) {}
  }

  Future<void> dispose() => _player.dispose();
}
