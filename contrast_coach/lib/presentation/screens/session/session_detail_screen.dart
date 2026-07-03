import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  String _formatDate(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m/$d/${dt.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final session = _session;
    if (session == null) {
      return Scaffold(
        appBar: const ContrastAppBar(title: 'Session detail', showBackButton: true),
        body: const Center(child: Text('Session not found')),
      );
    }
    final hot = _phaseDuration(PhaseType.sauna);
    final cold = _phaseDuration(PhaseType.cold);
    final rounds = session.roundsCompleted;
    final total = session.totalActualDuration;
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Session detail', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroCard(
              title: session.goal.name.toUpperCase(),
              subtitle: _formatDate(session.startedAt),
            ),
            const SizedBox(height: 16),
            _StatGrid(
              tiles: [
                _StatTile(label: 'Hot', value: _formatDuration(hot)),
                _StatTile(label: 'Cold', value: _formatDuration(cold)),
                _StatTile(label: 'Rounds', value: '$rounds'),
                _StatTile(label: 'Total', value: _formatDuration(total)),
              ],
            ),
            if (session.recoveryScore != null) ...[
              const SizedBox(height: 16),
              _RecoveryRow(score: session.recoveryScore!.round()),
            ],
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _NoteCard(note: session.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightLine, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.lightInk,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.lightInk2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.tiles});
  final List<_StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: tiles
          .map((t) => _StatCard(label: t.label, value: t.value))
          .toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightLine, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.lightInk3,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.lightInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryRow extends StatelessWidget {
  const _RecoveryRow({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightLine, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            const Text(
              'Recovery score',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightInk2,
              ),
            ),
            const Spacer(),
            ShaderMask(
              shaderCallback: (bounds) => AppGradients.scoreText.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                '$score',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightLine, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Note',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.lightInk3,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                height: 1.5,
                color: AppColors.lightInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
