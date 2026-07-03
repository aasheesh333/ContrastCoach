import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 History screen — mockup `#history`.
///
/// `.appbar` "History" h2.
/// One `.card` containing:
///   "July 2026" 800 weight + 8px bottom margin,
///   `.calh` 7-col M-S header (10 w700 ink3),
///   `.cal` 7-col grid: each cell aspect 1, radius 10, 12 w700 ink2 bg.
///   `.done` heat→coral gradient + white text,
///   `.cold` cold→cold2 gradient + white text,
///   `.today` 2px ink outline.
/// `.sec-t` "Recent sessions" 15 w800.
/// Two `.card.rowlink` rows: emoji + bold title + small "Today · 26:40 · Score 82".
class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenStreak();
}

class _StreakCalendarScreenStreak extends State<StreakCalendarScreen> {
  bool _loading = true;
  Set<DateTime> _doneDays = {};
  Set<DateTime> _coldDays = {};
  List<Session> _recent = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await DatabaseProvider.instance();
      final repo = SessionRepositoryImpl(db);
      final result = await repo.getAll();
      final sessions = result is Ok<List<Session>, AppException>
          ? result.value
          : <Session>[];
      final done = <DateTime>{};
      final cold = <DateTime>{};
      for (final s in sessions) {
        final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
        done.add(d);
        final hasCold = s.phases.any(
          (p) => p.type == PhaseType.cold && !p.skipped,
        );
        if (hasCold) cold.add(d);
      }
      final sorted = [...sessions]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      if (!mounted) return;
      setState(() {
        _doneDays = done;
        _coldDays = cold;
        _recent = sorted.take(2).toList(growable: false);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _monthLabel(DateTime dt) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month]} ${dt.year}';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _relativeDay(DateTime dt) {
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.month}/${dt.day}';
  }

  String _emojiFor(Session s) {
    if (s.goal == Goal.energy) return '⚡';
    if (s.goal == Goal.sleep) return '😴';
    return '🌡️';
  }

  String _titleFor(Goal g) {
    switch (g) {
      case Goal.recovery:
        return 'Standard Recovery';
      case Goal.energy:
        return 'Morning Energy';
      case Goal.sleep:
        return 'Deep Sleep';
      case Goal.immunity:
        return 'Immunity Boost';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = (monthStart.weekday - 1) % 7;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(title: 'History', showBackButton: true),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.huge,
                ),
                children: [
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _monthLabel(now),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _CalHeader(),
                        const SizedBox(height: 6),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1,
                          ),
                          itemCount: firstWeekday + daysInMonth,
                          itemBuilder: (context, i) {
                            if (i < firstWeekday) return const SizedBox();
                            final day = i - firstWeekday + 1;
                            final date = DateTime(now.year, now.month, day);
                            final isToday = date.day == now.day &&
                                date.month == now.month &&
                                date.year == now.year;
                            final isDone = _doneDays.any((d) =>
                                d.day == day && d.month == now.month && d.year == now.year);
                            final isCold = _coldDays.any((d) =>
                                d.day == day && d.month == now.month && d.year == now.year);
                            return _CalCell(
                              day: day,
                              isDone: isDone,
                              isCold: isCold && !isDone,
                              isToday: isToday,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 20, 2, 12),
                    child: Text(
                      'Recent sessions',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  for (final s in _recent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RowLink(
                        emoji: _emojiFor(s),
                        title: _titleFor(s.goal),
                        subtitle: '${_relativeDay(s.startedAt)} · '
                            '${_formatDuration(s.totalActualDuration)} · '
                            'Score ${s.recoveryScore?.round() ?? '--'}',
                        onTap: () => context.push('/session/${s.id}/detail'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}



class _CalHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(
                l,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalCell extends StatelessWidget {
  const _CalCell({
    required this.day,
    required this.isDone,
    required this.isCold,
    required this.isToday,
  });
  final int day;
  final bool isDone;
  final bool isCold;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Gradient? grad;
    Color fg = cs.onSurfaceVariant;
    if (isDone) {
      grad = AppGradients.btnPrimary;
      fg = Colors.white;
    } else if (isCold) {
      grad = AppGradients.btnCold;
      fg = Colors.white;
    }
    final cell = Container(
      decoration: BoxDecoration(
        gradient: grad,
        color: grad == null ? cs.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(10),
        border: isToday ? Border.all(color: cs.onSurface, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
    return cell;
  }
}

class _RowLink extends StatelessWidget {
  const _RowLink({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('›', style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
