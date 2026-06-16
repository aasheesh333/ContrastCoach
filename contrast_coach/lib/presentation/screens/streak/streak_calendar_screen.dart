import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/composite/streak_calendar.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});
  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  Set<DateTime> _daysWithSessions = {};
  Map<DateTime, int> _intensity = {};
  int _currentStreak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    final db = AppDatabase(key);
    final repo = SessionRepositoryImpl(db);

    final sessionsResult = await repo.getAll();
    if (sessionsResult is Ok<List<Session>, AppException>) {
      final sessions = sessionsResult.value;
      final dates = <DateTime>{};
      final counts = <DateTime, int>{};
      for (final s in sessions) {
        final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
        dates.add(d);
        counts[d] = (counts[d] ?? 0) + 1;
      }
      // Compute current streak
      var streak = 0;
      var cursor = DateTime.now();
      cursor = DateTime(cursor.year, cursor.month, cursor.day);
      while (dates.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
      if (mounted) {
        setState(() {
          _daysWithSessions = dates;
          _intensity = counts;
          _currentStreak = streak;
          _loading = false;
        });
      }
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Streak',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator(color: AppColors.brandWarm)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_currentStreak',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandWarm,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentStreak == 1 ? 'day streak' : 'days streak',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Last 12 weeks',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    StreakCalendar(
                      daysWithSessions: _daysWithSessions,
                      intensity: _intensity,
                    ),
                    const SizedBox(height: 20),
                    _Legend(),
                    const SizedBox(height: 32),
                    if (_daysWithSessions.isNotEmpty)
                      _RecentSessionsCard(days: _daysWithSessions),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: AppColors.midGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        for (final c in const [
          AppColors.heatmap0,
          AppColors.heatmap1,
          AppColors.heatmap2,
          AppColors.heatmap3,
          AppColors.heatmap4,
        ])
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(width: 8),
        const Text(
          'More',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: AppColors.midGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({required this.days});
  final Set<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final sorted = days.toList()..sort((a, b) => b.compareTo(a));
    final recent = sorted.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.midGray,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          for (final d in recent)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.brandWarm,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _format(d),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _format(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
