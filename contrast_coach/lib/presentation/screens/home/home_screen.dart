import 'dart:math' show pi;
import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/data/repositories/user_profile_service.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_pill.dart';
import 'package:contrast_coach/presentation/widgets/atomic/identity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SharedSubscriptionState _sharedState = SharedSubscriptionState.instance;
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
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AnimationUtils.standardDuration,
    );
    _entranceController.forward();
    _sharedState.addListener(_onTierChanged);
    _tier = _sharedState.tier.value;
    _load();
  }

  @override
  void dispose() {
    _sharedState.removeListener(_onTierChanged);
    _entranceController.dispose();
    super.dispose();
  }

  void _onTierChanged() {
    if (!mounted) return;
    setState(() => _tier = _sharedState.tier.value);
  }

  Future<void> _load() async {
    if (FirebaseAuthNullableProxy.tryGet() == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final db = await DatabaseProvider.instance();
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
    final repo2 = SubscriptionRepositoryImpl()
      ..bindSharedState(SharedSubscriptionState.instance);
    await repo2.currentTier();

    if (mounted) {
      setState(() {
        _stats = computeSessionStats(sessions);
        _recommended = pick;
        _profile = profile;
        _tier = _sharedState.tier.value;
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

  void _onExploreTap() => context.go('/explore');
  void _onResumeTap() => _onStartSession();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const ShimmerLoading(isLoading: true, child: _HomeSkeleton())
            : RefreshIndicator(
                color: AppColors.heat,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.pageTop,
                    AppSpacing.pageHorizontal,
                    AppSpacing.sectionGap,
                  ),
                  children: [
                    AnimationUtils.staggeredListItem(
                      animation: _entranceController,
                      index: 0,
                      child: _HomeHeader(profile: _profile),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimationUtils.staggeredListItem(
                      animation: _entranceController,
                      index: 1,
                      child: _HomeHeroCard(
                        stats: _stats,
                        onStart: _onStartSession,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    AnimationUtils.staggeredListItem(
                      animation: _entranceController,
                      index: 2,
                      child: _SectionHeader(
                        label: 'Quick start',
                        trailing: 'Explore',
                        onTrailingTap: _onExploreTap,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AnimationUtils.staggeredListItem(
                      animation: _entranceController,
                      index: 3,
                      child: _QuickStartGrid(
                        onStandard: () => _openProtocol('recovery_standard'),
                        onBreathwork: () => _openProtocol('breathwork_basic'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_stats.lastSession != null)
                      AnimationUtils.staggeredListItem(
                        animation: _entranceController,
                        index: 4,
                        child: _ResumeRow(
                          session: _stats.lastSession!,
                          onTap: () => context.push('/summary/${_stats.lastSession!.id}'),
                        ),
                      ),
                    AppButton(
                      label: '▶️ Start session',
                      onPressed: _onStartSession,
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                      size: AppButtonSize.large,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: _openCustomProtocolBuilder,
                        child: const Text(
                          'Build a custom protocol',
                          style: TextStyle(
                            color: AppColors.heat,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
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

/// v4 home header. Mockup `.name`:
///   greeting 13/w600/ls.4/Ink2; name 28/w800/ls-.7/Ink + 👋 emoji.
///   No avatar, no streak pill in the header row.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;
    final greeting = greetingForHour(hour);
    final hasName = profile.displayName.isNotEmpty;
    final name = hasName ? '${profile.firstName} 👋' : 'Welcome 👋';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: cs.onSurfaceVariant,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              height: 1.1,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// v4 home hero card. Mockup `.hero`:
///   140deg dark gradient `#12121a → #25252f`, radius 26, padding 20,
///   color #fff, box-shadow `0 22px 42px -20px rgba(255,107,53,.55)`
///   Contains:
///     - radial blob ::after (220x220 heat TR) and ::before (200x200 cold BL)
///     - .hw row: 100x100 gauge (heat→cold arc, 82/RECOVERY inner)
///       + right column: .lbl 'Today's readiness' 11/w700/ls.4/opacity .7
///                          .big readiness strapline 19/w800/ls-.3
///                          2 pills '🔥 7-day streak' / '⏱ 24m avg'
class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({required this.stats, required this.onStart});
  final SessionStats stats;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final score = (stats.lastScore ?? 82).round();
    final streakDays = stats.streakDays;
    final avgMin = stats.avgDurationMin == 0 ? 24 : stats.avgDurationMin;
    final readinessLabel = _readinessLabel(score);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.27, -1),
          end: Alignment(0.27, 1),
          colors: [Color(0xFF12121A), Color(0xFF25252F)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8CFF6B35),
            blurRadius: 42,
            offset: Offset(0, 22),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ::after heat TR blob
          Positioned(
            right: -70,
            top: -70,
            child: _RadialBlob(
              size: 220,
              color: const Color(0xFFFF6B35).withOpacity(0.55),
            ),
          ),
          // ::before cold BL blob
          Positioned(
            left: -70,
            bottom: -90,
            child: _RadialBlob(
              size: 200,
              color: const Color(0xFF2D7CF1).withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Gauge(value: score.toDouble()),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "TODAY'S READINESS",
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: Color(0xB3FFFFFF),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        readinessLabel,
                        style: const TextStyle(
                          fontFamily: AppTypography.displayFont,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppPill(label: '🔥 $streakDays-day streak'),
                          AppPill(label: '⏱ ${avgMin}m avg'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _readinessLabel(int score) {
    if (score >= 80) return 'Strong — go hard 🔥';
    if (score >= 60) return 'Solid — keep it steady';
    if (score >= 40) return 'Easy day — go gentle';
    return 'Rest, recover, retry';
  }
}

class _RadialBlob extends StatelessWidget {
  const _RadialBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
            stops: const [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}

/// v4 100x100 readiness gauge. CustomPainted arc:
///   - viewBox 0 0 120 120, r=50, stroke-width 11.
///   - base stroke rgba(255,255,255,.12).
///   - progress stroke heat→cold linear-gradient, sweeps proportionally.
///   - center: score 34px JetBrainsMono w500 #fff + 'RECOVERY' 10px white-.6.
class _Gauge extends StatelessWidget {
  const _Gauge({required this.value});
  final double value; // 0..100

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _GaugePainter(value.clamp(0, 100) / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${value.round()}',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontFamilyFallback: ['RobotoMono', 'monospace'],
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'RECOVERY',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0x99FFFFFF),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 11.0;
    const startAngle = -pi / 2;
    final sweep = 2 * pi * fraction;

    // Base ring (rgba(255,255,255,.12)) — full circle.
    final basePaint = Paint()
      ..color = const Color(0x1FFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, basePaint);

    // Progress arc with heat→cold sweep gradient.
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [AppColors.heat, AppColors.cold],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.fraction != fraction;
}

/// v4 section header. `.sec-t` 15/w800/ls-.2 with optional heat-trailing link.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing, this.onTrailingTap});
  final String label;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: cs.onSurface,
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              trailing!,
              style: const TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.heat,
              ),
            ),
          ),
      ],
    );
  }
}

/// v4 2-col quick-start grid. Mockup `.grid2` with two `.proto` cards:
///   Standard Recovery (🌡️, white14%) and Breathwork (🫧, blue14%).
class _QuickStartGrid extends StatelessWidget {
  const _QuickStartGrid({required this.onStandard, required this.onBreathwork});
  final VoidCallback onStandard;
  final VoidCallback onBreathwork;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lineColor = cs.outline;
    return Row(
      children: [
        Expanded(
          child: _QuickStartTile(
            emoji: '🌡️',
            iconBg: const Color(0xFFFFF0EA),
            iconColor: AppColors.heat,
            title: 'Standard Recovery',
            subtitle: '3× · 26m',
            cardColor: cs.surface,
            borderColor: lineColor,
            onTap: onStandard,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStartTile(
            emoji: '🫧',
            iconBg: const Color(0xFFEAF2FF),
            iconColor: AppColors.cold,
            title: 'Breathwork',
            subtitle: '4× · 8m',
            cardColor: cs.surface,
            borderColor: lineColor,
            onTap: onBreathwork,
          ),
        ),
      ],
    );
  }
}

class _QuickStartTile extends StatelessWidget {
  const _QuickStartTile({
    required this.emoji,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  final String emoji;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 18, height: 1),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  color: cs.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// v4 resume row. Mockup `.card.rowlink` slim inline row:
///   '▸ Resume last session' 13/w700 + 'Standard · 3 rounds' 11/Ink3 mt-2 + ⏯️ 20px right.
class _ResumeRow extends StatelessWidget {
  const _ResumeRow({required this.session, required this.onTap});
  final Session session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lineColor = cs.outline;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lineColor, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '▸ Resume last session',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Standard · ${session.protocolRounds} rounds',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('⏯️', style: TextStyle(fontSize: 20, height: 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.pageTop,
        AppSpacing.pageHorizontal,
        AppSpacing.sectionGap,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 80,
                      height: 14,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh),
                  const SizedBox(height: 8),
                  Container(
                      width: 120,
                      height: 24,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Container(
            width: 80,
            height: 16,
            color: Theme.of(context).colorScheme.surfaceContainerHigh),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(
            2,
            (_) => const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: _SkeletonBox(height: 100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.height = 48});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
