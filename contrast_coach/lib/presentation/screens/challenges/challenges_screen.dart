import 'dart:convert';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CHALLENGES screen (spec §3.2 row 5).
///
/// Renders active challenges and the weekly leaderboard from the static
/// `assets/challenges.json` bundle (spec §8 DoD — intentional static mock
/// data). The "You" leaderboard row uses the [AppColors.heat] accent so it
/// stands out per the v4 token system.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Map<String, dynamic>> _challenges = const [];
  List<Map<String, dynamic>> _leaderboard = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final raw = await rootBundle.loadString('assets/challenges.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _challenges =
            (decoded['challenges'] as List<dynamic>).cast<Map<String, dynamic>>();
        _leaderboard =
            (decoded['leaderboard'] as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _HeroHeader()),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _ErrorState(message: _error!),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeading(text: 'Challenges'),
                ),
              ),
              SliverList.separated(
                itemCount: _challenges.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _ChallengeTile(
                  challenge: _challenges[i],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sectionGap,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeading(text: 'Leaderboard'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sectionGap,
                ),
                sliver: SliverList.separated(
                  itemCount: _leaderboard.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _LeaderboardRow(
                    entry: _leaderboard[i],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Heat-tinted hero strip with the screen title, matching the Explore
/// screen's hero pattern (spec §3.2: v4 tokens + heat accent).
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.splashBg),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.pageTop + AppSpacing.xxl,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenges',
            style: AppTypography.titleHero.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Compete. Stay consistent.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTypography.titleHero.copyWith(color: cs.onSurface),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.challenge});
  final Map<String, dynamic> challenge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final emoji = (challenge['emoji'] as String?) ?? '';
    final title = (challenge['title'] as String?) ?? '';
    final description = (challenge['description'] as String?) ?? '';
    final goal = (challenge['goal'] as num?)?.toInt() ?? 0;
    final participants = (challenge['participants'] as num?)?.toInt() ?? 0;
    // Spec §3.2: live session progress would require a repo lookup; the
    // static screen shows each challenge as INCOMPLETE (progress = 0).
    const progress = 0;
    final progressFraction = goal > 0 ? (progress / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ext.lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                '$participants joined',
                style: AppTypography.captionV4.copyWith(color: ext.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(color: ext.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 6,
              backgroundColor: ext.lineColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.heat),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '0 / $goal',
            style: AppTypography.captionV4.copyWith(color: ext.textMuted),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});
  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final rank = (entry['rank'] as num?)?.toInt() ?? 0;
    final displayName = (entry['displayName'] as String?) ?? '';
    final points = (entry['points'] as num?)?.toInt() ?? 0;
    final isYou = (entry['isYou'] as bool?) ?? false;
    final accent = isYou ? AppColors.heat : cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isYou ? AppColors.heat.withOpacity(0.10) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isYou ? AppColors.heat.withOpacity(0.5) : ext.lineColor,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: AppTypography.labelMedium.copyWith(
                color: isYou ? AppColors.heat : ext.textMuted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              displayName,
              style: AppTypography.titleMedium.copyWith(color: accent),
            ),
          ),
          Text(
            '$points pts',
            style: AppTypography.labelMediumV4.copyWith(
              color: isYou ? AppColors.heat : ext.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧊', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load challenges.',
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(color: ext.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
