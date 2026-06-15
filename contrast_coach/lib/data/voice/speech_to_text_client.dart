import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextClient {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<bool> init() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      _available = await _stt.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({
    required void Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_available) return;
    await _stt.listen(
      onResult: (r) {
        if (r.finalResult) onResult(r.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(partialResults: false, cancelOnError: true),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    if (!_available) return;
    await _stt.stop();
  }
}
