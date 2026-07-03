import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/coach_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClient {
  GeminiClient({String? apiKey}) : _apiKey = apiKey ?? EnvConfig.geminiApiKey;

  final String? _apiKey;

  Future<Result<String, AppException>> complete(
    String prompt, {
    List<CoachMessage> history = const [],
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      return Err(NetworkException('Gemini API key not configured'));
    }
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _apiKey,
      );
      final chat = model.startChat(history: [
        for (final m in history)
          Content.text(m.content),
      ]);
      final response = await chat.sendMessage(Content.text(prompt));
      return Ok(response.text ?? '');
    } catch (e) {
      return Err(NetworkException('Gemini failed', cause: e));
    }
  }
}
