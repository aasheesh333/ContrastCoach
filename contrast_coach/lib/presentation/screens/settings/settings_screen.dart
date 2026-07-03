import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_motion.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/user_profile_service.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 PROFILE hub ("You"). Mockup #profile.
///
/// Layout: flat `.name` "You" 28/w800/ls-.7, avatar-bio-stats card, 11-emoji
/// rowlink tile list, "Go Pro" CTA. No AppBar.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile _profile = const UserProfile(
    uid: '',
    email: '',
    displayName: '',
    initials: 'C',
    photoURL: null,
    subscriptionStatus: 'free',
    createdAt: null,
  );
  SessionStats _stats = computeSessionStats(const []);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (FirebaseAuthNullableProxy.tryGet() == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    UserProfile profile = _profile;
    try {
      final profileService = UserProfileService(
        auth: FirebaseAuthNullableProxy.auth,
        firestore: FirebaseFirestore.instance,
      );
      final profileResult = await profileService.current();
      profile = profileResult is Ok<UserProfile, AppException>
          ? profileResult.value
          : _profile;
    } catch (_) {}

    List<Session> sessions = const [];
    try {
      final db = await DatabaseProvider.instance();
      final repo = SessionRepositoryImpl(db);
      final sessionsResult = await repo.getAll();
      sessions = sessionsResult is Ok<List<Session>, AppException>
          ? sessionsResult.value
          : <Session>[];
    } catch (_) {}

    if (mounted) {
      setState(() {
        _profile = profile;
        _stats = computeSessionStats(sessions);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: AppMotion.defaultDuration,
          child: _loading
              ? const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(color: AppColors.heat),
                )
              : KeyedSubtree(
                  key: const ValueKey('content'),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.huge,
                      AppSpacing.pageHorizontal,
                      AppSpacing.huge,
                    ),
                    children: [
                      _NameHeader(text: _profile.displayName.isEmpty ? 'Guest' : _profile.displayName),
                      const SizedBox(height: AppSpacing.lg + 4),
                      _ProfileHeroCard(
                        profile: _profile,
                        stats: _stats,
                        onEdit: () => context.push('/profile/edit'),
                      ),
                      const SizedBox(height: 12),
                      _RowlinkCard(lineColor: ext.lineColor, onSurfaceColor: cs.onSurface),
                      const SizedBox(height: 16),
                      _GoProButton(),
                      const SizedBox(height: AppSpacing.huge),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// v4 `.name` flat title 28/w800/ls-.7.
class _NameHeader extends StatelessWidget {
  const _NameHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'You',
      style: TextStyle(
        fontFamily: AppTypography.displayFont,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
        letterSpacing: -0.7,
        height: 1.1,
      ),
    );
  }
}

/// v4 profile hero card with 88×88 heat→cold gradient avatar (with emoji),
/// name, bio, stats trio (Streak/Longest/Sessions) + Edit profile ghost2 button.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.stats,
    required this.onEdit,
  });

  final UserProfile profile;
  final SessionStats stats;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    final hasName = profile.displayName.isNotEmpty;
    final displayName = hasName ? profile.displayName : 'Guest user';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ext.lineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E14142D),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar: 88×88 heat→cold gradient circle with emoji
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.27, -1),
                end: Alignment(0.27, 1),
                colors: [AppColors.heat, AppColors.cold],
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E14142D),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                  spreadRadius: -16,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              '🧑',
              style: TextStyle(fontSize: 34, height: 1.0),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Contrast therapy since 2024',
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Edit profile ghost2 button
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: ext.lineColor, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                'Edit profile',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats trio: Streak / Longest / Sessions
          Row(
            children: [
              _StatColumn(value: '${stats.streakDays}', label: 'Streak'),
              _StatColumn(value: '${_longestStreak(stats)}', label: 'Longest'),
              _StatColumn(value: '${stats.totalSessions}', label: 'Sessions'),
            ],
          ),
        ],
      ),
    );
  }

  int _longestStreak(SessionStats s) => s.streakDays > 0 ? s.streakDays : 0;
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// v4 rowlink card with 11 emoji-prefixed row entries.
class _RowlinkCard extends StatelessWidget {
  const _RowlinkCard({
    required this.lineColor,
    required this.onSurfaceColor,
  });

  final Color lineColor;
  final Color onSurfaceColor;

  static const _entries = <_Rowlink>[
    _Rowlink(emoji: '🏅', label: 'Achievements', subtext: 'Level 4 · 720 XP', location: '/achievements'),
    _Rowlink(emoji: '🗓️', label: 'History & calendar', subtext: '', location: '/history'),
    _Rowlink(emoji: '📝', label: 'Journal', subtext: '', location: '/journal'),
    _Rowlink(emoji: '🏆', label: 'Challenges', subtext: '', location: '/challenges'),
    _Rowlink(emoji: '🔐', label: 'Account & security', subtext: '', location: '/account'),
    _Rowlink(emoji: '🔔', label: 'Notifications', subtext: '', location: '/notifications'),
    _Rowlink(emoji: '🎨', label: 'Appearance', subtext: '', location: '/appearance'),
    _Rowlink(emoji: '❤️', label: 'Health Connect', subtext: '', location: '/settings/health'),
    _Rowlink(emoji: '🧩', label: 'Home-screen widgets', subtext: '', location: '/widgets'),
    _Rowlink(emoji: '⭐', label: 'Subscription', subtext: 'Free plan', location: '/subscription'),
    _Rowlink(emoji: '💾', label: 'Data & backup', subtext: '', location: '/settings/export'),
    _Rowlink(emoji: '❓', label: 'Help & support', subtext: '', location: '/help'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineColor, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _entries.length; i++)
            _RowlinkTile(
              entry: _entries[i],
              lineColor: lineColor,
              showDivider: i < _entries.length - 1,
              onSurfaceColor: onSurfaceColor,
            ),
        ],
      ),
    );
  }
}

class _Rowlink {
  const _Rowlink({
    required this.emoji,
    required this.label,
    required this.subtext,
    required this.location,
  });
  final String emoji;
  final String label;
  final String subtext;
  final String location;
}

class _RowlinkTile extends StatelessWidget {
  const _RowlinkTile({
    required this.entry,
    required this.lineColor,
    required this.showDivider,
    required this.onSurfaceColor,
  });

  final _Rowlink entry;
  final Color lineColor;
  final bool showDivider;
  final Color onSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(entry.location),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: lineColor, width: 1),
                  ),
                )
              : null,
          child: Row(
            children: [
              // Emoji tile 34×34 radius 11
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(entry.emoji, style: const TextStyle(fontSize: 16, height: 1.2)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  entry.label,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
              ),
              if (entry.subtext.isNotEmpty) ...[
                Text(
                  entry.subtext,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// v4 "Go Pro — 7-day free trial" button (heat→coral gradient).
class _GoProButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/paywall'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: AppGradients.btnPrimary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4DFF6B35),
              blurRadius: 26,
              offset: Offset(0, 14),
              spreadRadius: -12,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Go Pro — 7-day free trial',
          style: TextStyle(
            fontFamily: AppTypography.displayFont,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
