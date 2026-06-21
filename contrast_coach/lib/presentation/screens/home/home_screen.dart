import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/data/repositories/user_profile_service.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/identity.dart';
import 'package:contrast_coach/presentation/widgets/composite/hero_start_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/quick_stats_row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionStats _stats = computeSessionStats(const []);
  UserProfile _profile = const UserProfile(
    uid: '',
    email: '',
    displayName: '',
    initials: 'C',
    photoURL: null,
    subscriptionStatus: 'free',
    createdAt: null,
  );
  Protocol? _recommended;
  SubscriptionTier _tier = SubscriptionTier.free;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Tests don't wire up Firebase/Drift — bail out cleanly with empty state
    // so `pumpAndSettle` returns quickly.
    if (FirebaseAuthNullableProxy.tryGet() == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    final db = AppDatabase(key);
    final repo = SessionRepositoryImpl(db);

    final sessionsResult = await repo.getAll();
    final sessions = sessionsResult is Ok<List<Session>, AppException>
        ? sessionsResult.value
        : <Session>[];

    final protoRepo = ProtocolRepositoryImpl();
    final allResult = await protoRepo.getAll();
    final all = allResult is Ok<List<Protocol>, AppException>
        ? allResult.value
        : <Protocol>[];

    final hour = DateTime.now().hour;
    final hourRec = all.firstWhere(
      (p) => p.id == recommendedProtocolForHour(hour),
      orElse: () => all.isEmpty ? _placeholderProtocol() : all.first,
    );
    Protocol? pick = all.isEmpty ? null : hourRec;
    if (sessions.isNotEmpty && all.isNotEmpty) {
      final lastId = sessions.first.protocolId;
      final last = all.cast<Protocol?>().firstWhere(
            (p) => p?.id == lastId,
            orElse: () => null,
          );
      if (last != null) pick = last;
    }

    final profileService = UserProfileService(
      auth: FirebaseAuthNullableProxy.auth,
      firestore: FirebaseFirestore.instance,
    );
    final profileResult = await profileService.current();
    final profile = profileResult is Ok<UserProfile, AppException>
        ? profileResult.value
        : _profile;
    final tierResult = await SubscriptionRepositoryImpl().currentTier();
    final tier = tierResult is Ok<SubscriptionTier, AppException>
        ? tierResult.value
        : SubscriptionTier.free;

    if (mounted) {
      setState(() {
        _stats = computeSessionStats(sessions);
        _recommended = pick;
        _profile = profile;
        _tier = tier;
        _loading = false;
      });
    }
  }

  void _onStartSession() {
    final id = _recommended?.id ?? 'recovery_standard';
    _openProtocol(id);
  }

  void _openProtocol(String protocolId) {
    if (!FeatureGating.canAccessProtocol(protocolId, _tier)) {
      context.push('/paywall');
      return;
    }
    context.push('/session/$protocolId');
  }

  void _openCustomProtocolBuilder() {
    if (!FeatureGating.canUseCustomProtocols(_tier)) {
      context.push('/paywall');
      return;
    }
    context.push('/protocol/custom');
  }

  Protocol _placeholderProtocol() => Protocol(
        id: 'recovery_standard',
        name: 'Standard Recovery',
        description: '',
        category: ProtocolCategory.recovery,
        difficulty: ProtocolDifficulty.intermediate,
        rounds: 3,
        phases: const [],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brandWarm),
              )
            : RefreshIndicator(
                color: AppColors.brandWarm,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageTop,
                    AppSpacing.pageHorizontal,
                    AppSpacing.sectionGap,
                  ),
                  children: [
                    _HomeHeader(profile: _profile, stats: _stats),
                    const SizedBox(height: AppSpacing.lg),
                    _TodayPanel(
                      stats: _stats,
                      recommended: _recommended,
                      onStart: _onStartSession,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    QuickStatsRow(
                      streakDays: _stats.streakDays,
                      avgDurationMin: _stats.avgDurationMin,
                      lastScore: _stats.lastScore,
                      bestScore: _stats.bestScore,
                      totalMinutes: _stats.totalMinutes,
                      weekDelta: _stats.weekDelta,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    SectionHeader(
                      label: 'Pick a goal',
                      trailing: TextButton(
                        onPressed: _openCustomProtocolBuilder,
                        child: const Text(
                          'Custom',
                          style: TextStyle(
                            color: AppColors.brandWarm,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GoalCardsRow(onGoalTap: (g) {
                      final id = switch (g.name) {
                        'energy' => 'energy_morning',
                        'sleep' => 'sleep_evening',
                        'immunity' => 'immunity_weekly',
                        _ => 'recovery_standard',
                      };
                      _openProtocol(id);
                    }),
                    const SizedBox(height: AppSpacing.lg),
                    if (_stats.lastSession != null)
                      _RecentSessionCard(session: _stats.lastSession!),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profile, required this.stats});
  final UserProfile profile;
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = greetingForHour(hour);
    final hasName = profile.displayName.isNotEmpty;
    final line = hasName
        ? headerLineForHour(hour)
        : 'Pick a goal and start a session to begin tracking.';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    fontSize: 13,
                    color: AppColors.midGray,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasName ? '${profile.firstName}.' : 'Welcome.',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: AppColors.darkGray,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (stats.streakDays > 0) ...[
            _StreakPill(streak: stats.streakDays),
            const SizedBox(width: AppSpacing.sm),
          ],
          UserAvatar(
            initials: profile.initials,
            photoUrl: profile.photoURL,
            size: 44,
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.flame, color: AppColors.brandWarm, size: 14),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({
    required this.stats,
    required this.recommended,
    required this.onStart,
  });
  final SessionStats stats;
  final Protocol? recommended;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return _NoSessionsCard(onStart: onStart);
    }
    return HeroStartCard(
      recommendedProtocol: recommended,
      sessionCount: stats.totalSessions,
      onStart: onStart,
    );
  }
}

class _NoSessionsCard extends StatelessWidget {
  const _NoSessionsCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      radius: 28,
      elevation: AppCardElevation.medium,
      onTap: onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.brandWarm.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'FIRST SESSION',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brandWarm,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Start your first\ncontrast session.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A short, balanced protocol. Build streaks, see insights, and unlock the recovery score.',
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Material(
            color: AppColors.brandWarm,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onStart,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppShadows.pill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start first session',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(LucideIcons.arrowRight, color: AppColors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSessionCard extends StatelessWidget {
  const _RecentSessionCard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final mins = (session.totalActualDuration.inSeconds / 60).round();
    final goalLabel = _goalLabel(session.goal.name);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      radius: 20,
      elevation: AppCardElevation.soft,
      onTap: () => context.push('/summary/${session.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'Last session'),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalLabel,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.roundsCompleted}/${session.protocolRounds} rounds · ${mins}m',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.recoveryScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.brandWarm.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${session.recoveryScore!.round()}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandWarm,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _goalLabel(String name) => switch (name) {
      'energy' => 'Morning energy',
      'sleep' => 'Evening recovery',
      'immunity' => 'Immune boost',
      _ => 'Standard recovery',
    };
