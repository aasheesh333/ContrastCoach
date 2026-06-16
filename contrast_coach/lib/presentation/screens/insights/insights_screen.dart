import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/generate_insights.dart';
import 'package:contrast_coach/presentation/widgets/composite/insight_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

enum _Range { week, month, year }

class _InsightsScreenState extends State<InsightsScreen> {
  List<Insight> _insights = const [];
  _Range _range = _Range.month;
  bool _loading = true;
  int _totalSessions = 0;
  int _avgDuration = 0;
  int _currentStreak = 0;

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
      final period = switch (_range) {
        _Range.week => const Duration(days: 7),
        _Range.month => const Duration(days: 30),
        _Range.year => const Duration(days: 365),
      };
      _insights = generateInsights(sessions: sessions, periodEnd: DateTime.now(), period: period);
      _totalSessions = _insights
              .firstWhere(
                (i) => i.category == InsightCategory.totalSessions,
                orElse: () => Insight(
                  id: 'none',
                  category: InsightCategory.totalSessions,
                  heroMetric: '0',
                  title: 'Sessions',
                  body: 'No data yet',
                  periodStart: DateTime.now(),
                  periodEnd: DateTime.now(),
                ),
              )
              .heroMetric
              .toString()
              .trim()
              .isEmpty
          ? 0
          : int.tryParse(
                  _insights
                      .firstWhere((i) => i.category == InsightCategory.totalSessions)
                      .heroMetric,
                ) ??
              0;
      if (sessions.isNotEmpty) {
        final totalSec = sessions.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
        _avgDuration = (totalSec / sessions.length / 60).round();
      }
      // Streak
      final dates = sessions
          .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
          .toSet();
      var streak = 0;
      var cursor = DateTime.now();
      cursor = DateTime(cursor.year, cursor.month, cursor.day);
      while (dates.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
      _currentStreak = streak;
      if (mounted) setState(() => _loading = false);
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  String _monthLabel() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
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
          'Insights',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brandWarm))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        'Insights',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _monthLabel(),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Range chips
                    Row(
                      children: [
                        _RangeChip(label: 'Week', active: _range == _Range.week, onTap: () => _setRange(_Range.week)),
                        const SizedBox(width: 8),
                        _RangeChip(label: 'Month', active: _range == _Range.month, onTap: () => _setRange(_Range.month)),
                        const SizedBox(width: 8),
                        _RangeChip(label: 'Year', active: _range == _Range.year, onTap: () => _setRange(_Range.year)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Hero gradient stat
                    GradientHeroStat(
                      label: 'AVERAGE EFFORT',
                      value: '$_totalSessions',
                      delta: _currentStreak > 0
                          ? '$_currentStreak day streak · ${_avgDuration} min avg'
                          : 'No streak yet · start one today',
                    ),
                    const SizedBox(height: 16),
                    // 2x2 grid
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'SESSIONS',
                            value: '$_totalSessions',
                            icon: LucideIcons.activity,
                            color: AppColors.brandWarm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'AVG TIME',
                            value: '$_avgDuration',
                            suffix: 'min',
                            icon: LucideIcons.timer,
                            color: AppColors.brandCool,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'BEST',
                            value: 'Standard',
                            icon: LucideIcons.award,
                            color: AppColors.brandWarm,
                            isWide: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'SLEEP IMPACT',
                            value: '+23',
                            suffix: 'min',
                            icon: LucideIcons.moon,
                            color: AppColors.brandCool,
                            isWide: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Patterns',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    _BarRow(label: 'Morning sessions', value: '64%', fraction: 0.64, color: AppColors.brandWarm),
                    const SizedBox(height: 12),
                    _BarRow(label: 'Evening sessions', value: '36%', fraction: 0.36, color: AppColors.brandCool),
                    const SizedBox(height: 24),
                    // Insight cards
                    for (final i in _insights) ...[
                      if (i.category != InsightCategory.totalSessions && i.category != InsightCategory.avgDuration)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InsightBlock(
                            heroMetric: i.heroMetric,
                            title: i.title,
                            body: i.body,
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warmBeige,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Not medical advice. For informational purposes only.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: AppColors.midGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _setRange(_Range r) {
    if (_range == r) return;
    setState(() {
      _range = r;
      _loading = true;
    });
    _load();
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.charcoal : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: active ? AppColors.charcoal : AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: active ? AppColors.white : AppColors.charcoal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
    this.isWide = false,
  });
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  color: AppColors.midGray,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: isWide ? 20 : 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                    height: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix!,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: AppColors.midGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });
  final String label;
  final String value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ContrastBar(fraction: fraction, color: color),
      ],
    );
  }
}
