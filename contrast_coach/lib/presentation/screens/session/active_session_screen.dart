import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/data/audio/audio_cue_service.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/local/health/health_connect_client.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/data/voice/speech_to_text_client.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
  final AnalyticsApi? _analytics = AnalyticsApi.tryCreate();
  SubscriptionTier _tier = SubscriptionTier.free;
  bool _voiceActive = false;
  String? _lastLoggedTemp;

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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final sharedState = SharedSubscriptionState.instance;
    final repo = SubscriptionRepositoryImpl()..bindSharedState(sharedState);
    await repo.currentTier();
    final tier = sharedState.tier.value;
    if (!mounted) return;
    if (!FeatureGating.canAccessProtocol(widget.protocolId, tier)) {
      context.push('/paywall');
      return;
    }
    _tier = tier;
    final loaded = await _initSession();
    if (!loaded || !mounted) return;
    await _initVoice();
    _audio.playSessionStart();
    _analytics?.trackSessionStarted(widget.protocolId);
  }

  Future<bool> _initSession() async {
    final repo = ProtocolRepositoryImpl();
    final result = await repo.getById(widget.protocolId);
    if (!mounted) return false;
    bool ok = false;
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
        ok = true;
      },
    );
    return ok;
  }

  Future<void> _initVoice() async {
    if (!AppPreferences.voiceEnabled || !FeatureGating.canUseVoiceControl(_tier)) return;
    final hasPermission = await _stt.requestPermission();
    if (!hasPermission) return;
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
      case VoiceCommandKind.start:
        if (_paused) {
          if (mounted) setState(() => _paused = false);
          _ticker.start();
        }
      case VoiceCommandKind.repeat:
        _audio.playPhaseTransition();
        HapticFeedback.lightImpact();
      case VoiceCommandKind.logCold:
        if (mounted) {
          _lastLoggedTemp = 'cold';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged: feeling cold')),
          );
        }
      case VoiceCommandKind.logHot:
        if (mounted) {
          _lastLoggedTemp = 'hot';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged: feeling hot')),
          );
        }
      case VoiceCommandKind.unknown:
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
    HapticFeedback.lightImpact();

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

    HapticFeedback.mediumImpact();

    final healthData = await _tryCaptureHealthSnapshot();
    final session = _buildSession(healthSnapshot: healthData);
    await _saveSession(session);
    if (session.recoveryScore != null) {
      _analytics?.trackSessionCompleted(widget.protocolId, session.recoveryScore!);
    }
    if (mounted) context.pushReplacement('/summary/${session.id}');
  }

  Future<void> _handleEnd() async {
    _ticker.stop();
    _audio.playSessionComplete();

    HapticFeedback.mediumImpact();

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

    final healthData = await _tryCaptureHealthSnapshot();
    final session = _buildSession(healthSnapshot: healthData);
    await _saveSession(session);
    if (mounted) context.pushReplacement('/summary/${session.id}');
  }

  Future<Map<String, dynamic>?> _tryCaptureHealthSnapshot() async {
    try {
      final client = HealthConnectClient();
      final result = await client.readSnapshot();
      client.dispose();
      if (result.isOk) {
        final s = result is Ok<HealthSnapshot, AppException> ? result.value : null;
        if (s == null) return null;
        return {
          'capturedAt': s.capturedAt.toIso8601String(),
          if (s.lastNightSleepMinutes != null) 'lastNightSleepMinutes': s.lastNightSleepMinutes,
          if (s.hrvRmssd7DayAvg != null) 'hrvRmssd7DayAvg': s.hrvRmssd7DayAvg,
          if (s.hrvRmssdTrend7Day != null) 'hrvRmssdTrend7Day': s.hrvRmssdTrend7Day,
          if (s.restingHr7DayAvg != null) 'restingHr7DayAvg': s.restingHr7DayAvg,
          if (s.stepsYesterday != null) 'stepsYesterday': s.stepsYesterday,
        };
      }
    } catch (_) {}
    return null;
  }

  Session _buildSession({Map<String, dynamic>? healthSnapshot}) {
    final now = DateTime.now();
    final totalActual = _completedPhases.fold<Duration>(
      Duration.zero,
      (sum, p) => sum + (p.actualDuration ?? p.plannedDuration),
    );

    final session = Session(
      id: const Uuid().v4(),
      userId: FirebaseAuthNullableProxy.tryGet()?.currentUser?.uid,
      protocolId: widget.protocolId,
      goal: _goalFromProtocol(widget.protocolId),
      startedAt: _sessionStartedAt!,
      endedAt: now,
      totalPlannedDuration: _protocol!.totalDuration,
      totalActualDuration: totalActual,
      roundsCompleted: _currentRound,
      protocolRounds: _protocol!.rounds,
      recoveryScore: null,
      healthDataSnapshot: healthSnapshot,
      createdAt: now,
      updatedAt: now,
      phases: _completedPhases,
    );

    final sleepMinutes = healthSnapshot?['lastNightSleepMinutes'] as int?;
    final hrvTrend = healthSnapshot?['hrvRmssdTrend7Day'] as double?;
    final score = calculateRecoveryScore(
      session: session,
      lastNightSleepMinutes: sleepMinutes,
      hrvRmssdTrend7Day: hrvTrend,
    );

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
      healthDataSnapshot: healthSnapshot,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      phases: session.phases,
    );
  }

  Future<void> _saveSession(Session session) async {
    final db = await DatabaseProvider.instance();
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

  void _togglePause() {
    if (_paused) {
      setState(() => _paused = false);
      _ticker.start();
      return;
    }
    _totalPhaseElapsed += _lastElapsed;
    _ticker.stop();
    setState(() => _paused = true);
  }

  void _skipPhase() {
    if (_sessionComplete || _protocol == null) return;
    HapticFeedback.mediumImpact();
    _advanceToNextPhase(Duration.zero);
  }

  void _addTime() {
    if (_sessionComplete || _paused) return;
    HapticFeedback.lightImpact();
    setState(() {
      _remaining += const Duration(seconds: 30);
    });
  }

  void _confirmEnd() {
    if (_sessionComplete) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End session?'),
        content: const Text(
          'Your progress will be saved with the phases completed so far.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleEnd();
            },
            child: const Text('End session'),
          ),
        ],
      ),
    );
  }

  void _showVoiceStatus() {
    if (_voiceActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Text(
            "Listening. Say 'next phase' to continue.",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
      return;
    }

    if (!FeatureGating.canUseVoiceControl(_tier)) {
      context.push('/paywall');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          'Voice control is off. Enable it in Settings to use the mic during sessions.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.heat)),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $_error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Try again',
                  onPressed: () {
                    setState(() => _error = null);
                    _initSession();
                  },
                  variant: AppButtonVariant.warm,
                ),
              ],
            ),
          ),
        ),
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
              // Top: close button
              Positioned(
                top: 12,
                right: 16,
                child: _CloseButton(onPressed: _confirmEnd),
              ),
              // Center: timer + controls
              Center(
                child: SessionTimer(
                  phaseType: phaseType,
                  remaining: _remaining,
                  plannedDuration: _currentPhaseDuration,
                  currentRound: _currentRound + 1,
                  totalRounds: _protocol!.rounds,
                  targetTempC: _protocol!.phases[_currentPhaseIndex].targetTempC,
                  onPause: _togglePause,
                  onMic: _showVoiceStatus,
                ),
              ),
              // Bottom: manual controls + end session
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionChip(label: 'Skip', onPressed: _skipPhase),
                        const SizedBox(width: 8),
                        _ActionChip(label: '+30s', onPressed: _addTime),
                        const SizedBox(width: 8),
                        _ActionChip(label: 'End', onPressed: _confirmEnd),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _confirmEnd,
                      child: Text(
                        'End session',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// v4 close button for active session screen.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text('×', style: TextStyle(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.w300)),
      ),
    );
  }
}

/// v4 action chip for skip/+30s/end controls.
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.white.withOpacity(0.15)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// Animates between warm and cold radial gradients based on phase.
class ActiveSessionBackground extends StatelessWidget {
  const ActiveSessionBackground({
    super.key,
    required this.child,
    required this.phaseType,
  });

  final Widget child;
  final PhaseType phaseType;

  @override
  Widget build(BuildContext context) {
    final isCold = phaseType == PhaseType.cold;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: isCold ? AppGradients.sessionCold : AppGradients.sessionWarm,
      ),
      child: child,
    );
  }
}
