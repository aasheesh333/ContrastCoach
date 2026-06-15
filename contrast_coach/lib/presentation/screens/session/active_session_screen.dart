import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/data/audio/audio_cue_service.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/voice/speech_to_text_client.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key, required this.protocolId});
  final String protocolId;

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen>
    with TickerProviderStateMixin {
  Protocol? _protocol;
  bool _loading = true;
  String? _error;

  int _totalPhasesCompleted = 0;
  Duration _currentPhaseDuration = Duration.zero;
  Duration _remaining = Duration.zero;
  Duration _totalPhaseElapsed = Duration.zero;
  Duration _lastElapsed = Duration.zero;
  bool _paused = false;
  bool _sessionComplete = false;
  DateTime? _sessionStartedAt;
  DateTime? _phaseStartTime;
  final List<Phase> _completedPhases = [];

  late final Ticker _ticker;
  final SpeechToTextClient _stt = SpeechToTextClient();
  final AudioCueService _audio = AudioCueService();
  bool _voiceActive = false;

  int get _currentRound => _totalPhasesCompleted ~/ (_protocol?.phases.length ?? 1);
  int get _currentPhaseIndex => _totalPhasesCompleted % (_protocol?.phases.length ?? 1);
  bool get _allRoundsComplete {
    if (_protocol == null) return false;
    return _currentRound >= _protocol!.rounds;
  }

  Goal _goalFromProtocol(String id) => switch (id) {
        'energy_morning' => Goal.energy,
        'sleep_evening' => Goal.sleep,
        'immunity_weekly' => Goal.immunity,
        _ => Goal.recovery,
      };

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _initSession();
    _initVoice();
    _audio.playSessionStart();
  }

  Future<void> _initSession() async {
    final repo = ProtocolRepositoryImpl();
    final result = await repo.getById(widget.protocolId);
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _error = err.message;
        _loading = false;
      }),
      (protocol) {
        if (protocol == null) {
          setState(() {
            _error = 'Protocol not found';
            _loading = false;
          });
          return;
        }
        _sessionStartedAt = DateTime.now();
        _phaseStartTime = DateTime.now();
        _totalPhaseElapsed = Duration.zero;
        _currentPhaseDuration = protocol.phases[0].duration;
        _remaining = _currentPhaseDuration;
        _ticker.start();
        setState(() {
          _protocol = protocol;
          _loading = false;
        });
      },
    );
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
        _advanceToNextPhase(_totalPhaseElapsed + _lastElapsed);
      case VoiceCommandKind.pause:
        _totalPhaseElapsed += _lastElapsed;
        _ticker.stop();
        if (mounted) setState(() => _paused = true);
      case VoiceCommandKind.resume:
        if (mounted) setState(() => _paused = false);
        _ticker.start();
      case VoiceCommandKind.end:
        _handleEnd();
      case VoiceCommandKind.howLong:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_remaining.inMinutes}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining',
              ),
            ),
          );
        }
      default:
        break;
    }
  }

  void _onTick(Duration elapsed) {
    _lastElapsed = elapsed;
    if (_sessionComplete) return;
    if (_paused) return;

    final remaining = _currentPhaseDuration - (_totalPhaseElapsed + elapsed);

    if (remaining <= Duration.zero) {
      _advanceToNextPhase(_totalPhaseElapsed + elapsed);
    } else {
      setState(() => _remaining = remaining);
    }
  }

  void _advanceToNextPhase(Duration actualDuration) {
    _ticker.stop();
    _audio.playPhaseTransition();

    final template = _protocol!.phases[_currentPhaseIndex];
    _completedPhases.add(Phase(
      id: const Uuid().v4(),
      type: template.type,
      orderIndex: _completedPhases.length,
      plannedDuration: template.duration,
      actualDuration: actualDuration < template.duration
          ? actualDuration
          : template.duration,
      targetTempC: template.targetTempC,
      startedAt: _phaseStartTime!,
      endedAt: DateTime.now(),
    ));
    _totalPhasesCompleted++;

    if (_allRoundsComplete) {
      _onSessionComplete();
    } else {
      setState(() {
        _totalPhaseElapsed = Duration.zero;
        _phaseStartTime = DateTime.now();
        _currentPhaseDuration = _protocol!.phases[_currentPhaseIndex].duration;
        _remaining = _currentPhaseDuration;
        _ticker.start();
      });
    }
  }

  Future<void> _onSessionComplete() async {
    _ticker.stop();
    _audio.playSessionComplete();
    setState(() => _sessionComplete = true);

    final session = _buildSession();
    await _saveSession(session);
    if (mounted) context.push('/summary/${session.id}');
  }

  Future<void> _handleEnd() async {
    _ticker.stop();
    _audio.playSessionComplete();

    final template = _protocol!.phases[_currentPhaseIndex];
    _completedPhases.add(Phase(
      id: const Uuid().v4(),
      type: template.type,
      orderIndex: _completedPhases.length,
      plannedDuration: template.duration,
      actualDuration: _totalPhaseElapsed + _lastElapsed,
      targetTempC: template.targetTempC,
      startedAt: _phaseStartTime!,
      endedAt: DateTime.now(),
    ));

    setState(() => _sessionComplete = true);

    final session = _buildSession();
    await _saveSession(session);
    if (mounted) context.push('/summary/${session.id}');
  }

  Session _buildSession() {
    final now = DateTime.now();
    final totalActual = _completedPhases.fold<Duration>(
      Duration.zero,
      (sum, p) => sum + (p.actualDuration ?? p.plannedDuration),
    );

    final session = Session(
      id: const Uuid().v4(),
      protocolId: widget.protocolId,
      goal: _goalFromProtocol(widget.protocolId),
      startedAt: _sessionStartedAt!,
      endedAt: now,
      totalPlannedDuration: _protocol!.totalDuration,
      totalActualDuration: totalActual,
      roundsCompleted: _currentRound,
      protocolRounds: _protocol!.rounds,
      recoveryScore: null,
      createdAt: now,
      updatedAt: now,
      phases: _completedPhases,
    );

    final score = calculateRecoveryScore(session: session);

    return Session(
      id: session.id,
      userId: session.userId,
      protocolId: session.protocolId,
      goal: session.goal,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      totalPlannedDuration: session.totalPlannedDuration,
      totalActualDuration: session.totalActualDuration,
      roundsCompleted: session.roundsCompleted,
      protocolRounds: session.protocolRounds,
      recoveryScore: score.value,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      phases: session.phases,
    );
  }

  Future<void> _saveSession(Session session) async {
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    final db = AppDatabase(key);
    final repo = SessionRepositoryImpl(db);
    await repo.save(session);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stt.stopListening();
    _audio.dispose();
    super.dispose();
  }

  String _phaseLabel(PhaseType type) => switch (type) {
        PhaseType.sauna => 'Sauna',
        PhaseType.cold => 'Cold',
        PhaseType.rest => 'Rest',
        PhaseType.custom => 'Custom',
      };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading session...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $_error'),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Go back',
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SessionTimer(
                phaseLabel: _phaseLabel(_protocol!.phases[_currentPhaseIndex].type),
                remaining: _remaining,
                currentRound: _currentRound + 1,
                totalRounds: _protocol!.rounds,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        label: _paused ? 'Resume' : 'Pause',
                        onPressed: () {
                          if (_paused) {
                            setState(() => _paused = false);
                            _ticker.start();
                          } else {
                            _totalPhaseElapsed += _lastElapsed;
                            _ticker.stop();
                            setState(() => _paused = true);
                          }
                        },
                        variant: AppButtonVariant.secondary,
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        label: 'End',
                        onPressed: _handleEnd,
                        variant: AppButtonVariant.text,
                      ),
                    ],
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
