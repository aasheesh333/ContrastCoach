import 'package:contrast_coach/data/audio/audio_cue_service.dart';
import 'package:contrast_coach/data/voice/speech_to_text_client.dart';
import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:flutter/material.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Duration _remaining = const Duration(minutes: 15);
  bool _paused = false;
  int _currentRound = 1;
  final int _totalRounds = 3;
  final String _phase = 'Sauna';
  final SpeechToTextClient _stt = SpeechToTextClient();
  final AudioCueService _audio = AudioCueService();
  bool _voiceActive = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
    _audio.playSessionStart();
  }

  Future<void> _initVoice() async {
    final ok = await _stt.init();
    if (ok && mounted) {
      setState(() => _voiceActive = true);
      _startListening();
    }
  }

  Future<void> _startListening() async {
    await _stt.startListening(onResult: _onVoiceResult);
  }

  void _onVoiceResult(String text) {
    final cmd = parseVoiceCommand(text);
    switch (cmd.kind) {
      case VoiceCommandKind.next:
        _audio.playPhaseTransition();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Next phase')));
        break;
      case VoiceCommandKind.pause:
        setState(() => _paused = true);
        break;
      case VoiceCommandKind.resume:
        setState(() => _paused = false);
        break;
      case VoiceCommandKind.end:
        _audio.playSessionComplete();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _stt.stopListening();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SessionTimer(
                phaseLabel: _phase,
                remaining: _remaining,
                currentRound: _currentRound,
                totalRounds: _totalRounds,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _voiceActive
                        ? "Say 'next phase' to continue"
                        : 'Tap a button to control the session',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _paused ? 'Resume' : 'Pause',
                    onPressed: () => setState(() => _paused = !_paused),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
