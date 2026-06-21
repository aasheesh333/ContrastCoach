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

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState() => _HomeScreenState(); }

class _HomeScreenState extends State<HomeScreen> {
  SessionStats _stats = computeSessionStats(const []);
  List<Session> _sessions = [];
  bool _loading = true; String? _error;
  String _userName = '', _userPhoto = '', _subscriptionStatus = 'Free';

  @override void initState() { super.initState(); _loadProfileAndSessions(); }

  Future<void> _loadProfileAndSessions() async {
    try {
      final key = await SqlcipherKeyProvider(storage: const FlutterSecureStorage()).getKey();
      if (key == null || !mounted) return;
      final db = AppDatabase(key);
      final sRepo = SessionRepository(db: db);
      final subRepo = SubscriptionRepositoryImpl();
      final uService = UserProfileService(firestore: FirebaseFirestore.instance, auth: FirebaseAuthNullableProxy.tryGet());
      final userResult = await uService.getProfile();
      final tier = (await subRepo.getTier()).getOrElse(SubscriptionTier.free);
      final r = await sRepo.getAllSessions();
      if (!mounted) return;
      r.fold((err) => setState(() { _loading = false; _error = err.message; }), (sessions) {
        userResult.fold((_) {}, (p) { _userName = '${p.firstName} ${p.lastName}'.trim(); _userPhoto = p.photoUrl ?? ''; });
        setState(() { _sessions = sessions; _stats = computeSessionStats(sessions); _subscriptionStatus = tier.name; _loading = false; });
      });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now(); final hour = now.hour;
    final greeting = greetingForHour(hour);
    final headerLine = headerLineForHour(hour);
    final initials = _userName.isEmpty ? 'CC' : _userName.split(' ').map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join().substring(0, 2.clamp(0, 2));
    final padX = AppSpacing.adaptiveX(context);

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.alertTriangle, size: 48, color: cs.error), const SizedBox(height: 16),
      Text(_error!, style: cs.textTheme.bodyLarge), const SizedBox(height: 16),
      ElevatedButton(onPressed: () { setState(() { _loading = true; _error = null; }); _loadProfileAndSessions(); }, child: const Text('Retry')),
    ])));

    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(padX, AppSpacing.adaptiveTop(context), padX, AppSpacing.adaptiveBottom(context)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        UserAvatar(initials: initials, photoUrl: _userPhoto.isNotEmpty ? _userPhoto : null, size: 40),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting, style: cs.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(headerLine, style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ])),
        PlanBadge(subscriptionStatus: _subscriptionStatus, onTap: () => context.push('/paywall')),
      ]),
      const SizedBox(height: AppSpacing.xxl),
      QuickStatsRow(stats: _stats),
      const SizedBox(height: AppSpacing.xxl),
      const SectionHeader(label: "Today's session"),
      HeroStartCard(recommendedProtocol: null, sessionCount: _sessions.length, onStart: () => context.push('/session/active')),
      const SizedBox(height: AppSpacing.xxl),
      if (_sessions.isNotEmpty) ...[
        const SectionHeader(label: 'Last session'),
        _LastSessionCard(session: _sessions.first),
        const SizedBox(height: AppSpacing.xxl),
      ],
      if (_sessions.isEmpty) AppEmptyState(icon: LucideIcons.thermometer, title: 'No sessions yet', message: 'Start your first contrast therapy session to see your progress here.',
        action: AppButton(label: 'Start session', onPressed: () => context.push('/session/active'), variant: AppButtonVariant.warm)),
    ]))));
  }
}

class _LastSessionCard extends StatelessWidget {
  const _LastSessionCard({required this.session}); final Session session;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mins = session.totalDuration.inMinutes;
    return AppCard.section(onTap: () => context.push('/session/summary/${session.id}'), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: cs.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(LucideIcons.timer, color: cs.primary, size: 20)),
      const SizedBox(width: AppSpacing.lg),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_goalLabel(session.goal.name), style: cs.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 2),
        Text('${session.roundsCompleted}/${session.protocolRounds} rounds · ${mins}m', style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ])),
      if (session.recoveryScore != null) Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: cs.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(999)), child: Text('${session.recoveryScore!.round()}', style: cs.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary))),
    ]));
  }
}

String _goalLabel(String name) => switch (name) { 'energy' => 'Morning energy', 'sleep' => 'Evening recovery', 'immunity' => 'Immune boost', _ => 'Standard recovery' };
