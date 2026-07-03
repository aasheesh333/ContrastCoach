import 'dart:convert';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Session detail — mockup `#detail`.
///
/// `.appbar` "Session detail" h2.
/// `.score` `.n` 70px w800 heat→cold text-clip gradient (ShaderMask),
///   `.s` 14 w800 ok-green "STRONG · Standard Recovery".
/// `.card.list` — 5 flat rows separated by 1px line, each row flex:
///   ⏱ Duration, 🔁 Rounds, 🌡️ Max heat, ❄️ Min cold, ❤️ HRV after.
/// `.sec-t` "Phase breakdown" 15 w800.
/// `.bars` 6 cells, heat→coral gradient, flex row 8px gap, 70 tall.
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Session? _session;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Session? resolved;
    try {
      final db = await DatabaseProvider.instance();
      final repo = SessionRepositoryImpl(db);
      final result = await repo.getById(widget.sessionId);
      if (result is Ok<Session?, AppException>) {
        resolved = result.value;
      }
    } catch (_) {
      resolved = null;
    }
    if (!mounted) return;
    setState(() {
      _session = resolved;
      _loaded = true;
    });
  }

  Duration _phaseDuration(PhaseType type) {
    final session = _session;
    if (session == null) return Duration.zero;
    var total = Duration.zero;
    for (final phase in session.phases) {
      if (phase.type == type && !phase.skipped) {
        total += phase.actualDuration ?? phase.plannedDuration;
      }
    }
    return total;
  }

  double? _maxHeat() {
    final session = _session;
    if (session == null) return null;
    double? maxC;
    for (final p in session.phases) {
      if (p.type != PhaseType.sauna || p.skipped) continue;
      final t = p.actualTempC ?? p.targetTempC;
      if (t != null && (maxC == null || t > maxC)) maxC = t;
    }
    return maxC;
  }

  double? _minCold() {
    final session = _session;
    if (session == null) return null;
    double? minC;
    for (final p in session.phases) {
      if (p.type != PhaseType.cold || p.skipped) continue;
      final t = p.actualTempC ?? p.targetTempC;
      if (t != null && (minC == null || t < minC)) minC = t;
    }
    return minC;
  }

  int? _hrvAfter() {
    final raw = _session?.healthDataSnapshot;
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final v = map['hrvAfter'] ?? map['hrv'] ?? map['HrvAfter'];
      if (v is num) return v.toInt();
    } catch (_) {}
    return null;
  }

  String _bandLabel(double? score) {
    if (score == null) return '—';
    final i = score.round();
    if (i >= 85) return 'STRONG';
    if (i >= 65) return 'MODERATE';
    return 'LOW';
  }

  String _title() {
    final g = _session?.goal;
    switch (g) {
      case Goal.recovery:
        return 'Standard Recovery';
      case Goal.energy:
        return 'Morning Energy';
      case Goal.sleep:
        return 'Deep Sleep';
      case Goal.immunity:
        return 'Immunity Boost';
      case null:
        return '';
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<double> _phaseBars() {
    final phases = _session?.phases.where((p) => !p.skipped).toList() ?? const [];
    if (phases.isEmpty) return const [0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
    final maxSec = phases.fold<int>(
      0,
      (a, p) => (a > (p.actualDuration ?? p.plannedDuration).inSeconds)
          ? a
          : (p.actualDuration ?? p.plannedDuration).inSeconds,
    );
    if (maxSec <= 0) return List.filled(phases.length, 0.5);
    final heights = <double>[];
    for (var i = 0; i < 6; i++) {
      if (i < phases.length) {
        heights.add((phases[i].actualDuration ?? phases[i].plannedDuration).inSeconds / maxSec);
      } else {
        heights.add(0.0);
      }
    }
    return heights;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session == null) {
      return Scaffold(
        appBar: const ContrastAppBar(title: 'Session detail', showBackButton: true),
        body: const Center(child: Text('Session not found')),
      );
    }
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final score = _session!.recoveryScore;
    final band = _bandLabel(score);
    final maxHeat = _maxHeat();
    final minCold = _minCold();
    final hrv = _hrvAfter();
    final rows = <_ListRow>[
      _ListRow(emoji: '⏱', label: 'Duration',
          value: _formatDuration(_session!.totalActualDuration)),
      _ListRow(emoji: '🔁', label: 'Rounds',
          value: '${_session!.roundsCompleted}'),
      _ListRow(emoji: '🌡️', label: 'Max heat',
          value: maxHeat == null ? '—' : '${maxHeat.round()}°C'),
      _ListRow(emoji: '❄️', label: 'Min cold',
          value: minCold == null ? '—' : '${minCold.round()}°C'),
      _ListRow(emoji: '❤️', label: 'HRV after',
          value: hrv == null ? '—' : '$hrv ms'),
    ];
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(title: 'Session detail', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => AppGradients.scoreText.createShader(b),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        '${score?.round() ?? '—'}',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 70,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$band · ${_title()}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      rows[i],
                      if (i < rows.length - 1)
                        Container(height: 1, color: ext.lineColor),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 12),
                child: Text(
                  'Phase breakdown',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: cs.onSurface,
                  ),
                ),
              ),
              _PhaseBars(heights: _phaseBars()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.emoji, required this.label, required this.value});
  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseBars extends StatelessWidget {
  const _PhaseBars({required this.heights});
  final List<double> heights;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: FractionallySizedBox(
                heightFactor: heights[i] == 0 ? 0.05 : heights[i].clamp(0.05, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(5),
                      bottom: Radius.zero,
                    ),
                    gradient: AppGradients.btnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
