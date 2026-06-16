import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/composite/hero_start_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/quick_stats_row.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streakDays = 0;
  int _avgDurationMin = 0;
  double? _lastScore;
  Protocol? _recommended;

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

    _streakDays = await repo.getStreakDays();

    final sessionsResult = await repo.getAll();
    if (sessionsResult is Ok<List<Session>, AppException>) {
      final sessions = sessionsResult.value;
      if (sessions.isNotEmpty) {
        final totalSec = sessions.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
        _avgDurationMin = (totalSec / sessions.length / 60).round();
        _lastScore = sessions.first.recoveryScore;
      }
    }

    // Recommend last-used protocol, else first free protocol
    final protoRepo = ProtocolRepositoryImpl();
    final allResult = await protoRepo.getAll();
    if (allResult is Ok<List<Protocol>, AppException>) {
      final all = allResult.value;
      Protocol? pick;
      if (sessionsResult is Ok<List<Session>, AppException> && sessionsResult.value.isNotEmpty) {
        final lastId = sessionsResult.value.first.protocolId;
        pick = all.cast<Protocol?>().firstWhere((p) => p?.id == lastId, orElse: () => null);
      }
      _recommended = pick ?? all.firstWhere((p) => p.id == 'recovery_standard', orElse: () => all.first);
    }

    if (mounted) setState(() {});
  }

  void _onGoalTap(Goal goal) {
    final id = switch (goal) {
      Goal.recovery => 'recovery_standard',
      Goal.energy => 'energy_morning',
      Goal.sleep => 'sleep_evening',
      Goal.immunity => 'immunity_weekly',
    };
    context.push('/session/$id');
  }

  void _onStartSession() {
    final id = _recommended?.id ?? 'recovery_standard';
    context.push('/session/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: _HomeHeader(streakDays: _streakDays),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: HeroStartCard(
                  recommendedProtocol: _recommended,
                  onStart: _onStartSession,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: QuickStatsRow(
                  streakDays: _streakDays,
                  avgDurationMin: _avgDurationMin,
                  lastScore: _lastScore,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pick a goal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/protocol/custom'),
                      child: const Text(
                        'Custom',
                        style: TextStyle(
                          color: AppColors.brandWarm,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GoalCardsRow(onGoalTap: _onGoalTap),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.streakDays});
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: AppColors.midGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ready when you are.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          // Streak pill
          if (streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.brandWarm, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$streakDays day streak',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.brandWarm, AppColors.brandCoral],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
