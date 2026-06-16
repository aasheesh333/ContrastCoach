import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/data/audio/audio_cue_service.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
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
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
  final AnalyticsApi _analytics = AnalyticsApi(FirebaseAnalytics.instance);
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
    _analytics.trackSessionStarted(widget.protocolId);
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
    if (session.recoveryScore != null) {
      _analytics.trackSessionCompleted(widget.protocolId, session.recoveryScore!);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.charcoal,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    final phaseType = _protocol!.phases[_currentPhaseIndex].type;
    return ActiveSessionBackground(
      phaseType: phaseType,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Top: phase pills + close
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final t in PhaseType.values.where((t) => t != PhaseType.custom))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PhasePill(type: t, active: t == phaseType),
                      ),
                  ],
                ),
              ),
              // Center: timer
              Center(
                child: SessionTimer(
                  phaseType: phaseType,
                  remaining: _remaining,
                  currentRound: _currentRound + 1,
                  totalRounds: _protocol!.rounds,
                  onPause: () {
                    if (_paused) {
                      setState(() => _paused = false);
                      _ticker.start();
                    } else {
                      _totalPhaseElapsed += _lastElapsed;
                      _ticker.stop();
                      setState(() => _paused = true);
                    }
                  },
                  onMic: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.white.withOpacity(0.9),
                        content: Text(
                          _voiceActive
                              ? "Listening. Say 'next phase' to continue."
                              : 'Tap to enable voice control in Settings.',
                          style: const TextStyle(color: AppColors.charcoal),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom: end button
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton(
                    onPressed: _handleEnd,
                    child: const Text(
                      'End session',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
