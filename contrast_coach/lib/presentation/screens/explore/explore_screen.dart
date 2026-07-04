import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_pro_lock_badge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 Explore category metadata: tinted .ic tile bg + emoji + accent.
/// Source: docs/mockups/v4/index.html for each `.proto` tile.
const Map<String, _CategoryStyle> _categoryStyles = {
  'recovery': _CategoryStyle(emoji: '🌡️', bg: Color(0xFFFFF0EA), accent: AppColors.heat),
  'energy':   _CategoryStyle(emoji: '⚡',  bg: Color(0xFFEAF2FF), accent: AppColors.cold),
  'sleep':    _CategoryStyle(emoji: '🌙', bg: Color(0xFFF0ECFF), accent: Color(0xFF7A5BFF)),
  'immunity': _CategoryStyle(emoji: '🛡️', bg: Color(0xFFEAFAF0), accent: Color(0xFF33C27F)),
  'cold':     _CategoryStyle(emoji: '🧊', bg: Color(0xFFEEF1FF), accent: AppColors.cold),
};

class _CategoryStyle {
  const _CategoryStyle({required this.emoji, required this.bg, required this.accent});
  final String emoji;
  final Color bg;
  final Color accent;
}

enum _Filter { all, recovery, energy, sleep, cold }

const Map<_Filter, String> _filterLabels = {
  _Filter.all:      'All',
  _Filter.recovery: 'Recovery',
  _Filter.energy:   'Energy',
  _Filter.sleep:    'Sleep',
  _Filter.cold:     'Cold',
};

/// v4 Explore screen — flat `.name` title + 5-chip filter row + 30-day
/// program hero (`heroDark`+cold shadow+bar-p) + 6-card protocol grid.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<Result<List<Protocol>, AppException>> _loadFuture;
  final SharedSubscriptionState _sharedState = SharedSubscriptionState.instance;
  SubscriptionTier _tier = SubscriptionTier.free;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _loadFuture = ProtocolRepositoryImpl().getAll();
    _sharedState.addListener(_onTierChanged);
    _tier = _sharedState.tier.value;
  }

  @override
  void dispose() {
    _sharedState.removeListener(_onTierChanged);
    super.dispose();
  }

  void _onTierChanged() {
    if (!mounted) return;
    setState(() => _tier = _sharedState.tier.value);
  }

  bool _matches(Protocol p) {
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.recovery:
        return p.category == ProtocolCategory.recovery;
      case _Filter.energy:
        return p.category == ProtocolCategory.energy;
      case _Filter.sleep:
        return p.category == ProtocolCategory.sleep;
      case _Filter.cold:
        return p.category == ProtocolCategory.recovery
            || p.category == ProtocolCategory.energy;
    }
  }

  void _open(Protocol p) {
    if (p.isCustom) {
      if (!FeatureGating.canUseCustomProtocols(_tier)) {
        context.push('/paywall');
        return;
      }
      context.push('/protocol/custom');
      return;
    }
    if (!FeatureGating.canAccessProtocol(p.id, _tier)) {
      context.push('/paywall');
      return;
    }
    context.push('/session/${p.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.pageTop,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ExploreTitle(),
                  const SizedBox(height: AppSpacing.sm),
                  _FilterRow(
                    selected: _filter,
                    onTap: (f) => setState(() => _filter = f),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ProgramHero(),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            const _AllProtocolsLabel(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: FutureBuilder<Result<List<Protocol>, AppException>>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.heat));
                  }
                  final result = snapshot.data;
                  if (result == null) {
                    return const _EmptyState(text: 'No protocols available.');
                  }
                  return result.fold(
                    (err) => _EmptyState(text: err.message),
                    (protocols) {
                      final filtered = protocols.where(_matches).toList(growable: false);
                      if (filtered.isEmpty) {
                        return const _EmptyState(text: 'No protocols in this category.');
                      }
                      return _ProtocolGrid(
                        protocols: filtered,
                        tier: _tier,
                        onTap: _open,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4 `.name` — flat 28/w800/ls-.7 title (NOT a hero strip).
class _ExploreTitle extends StatelessWidget {
  const _ExploreTitle();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'Explore',
      style: TextStyle(
        fontFamily: AppTypography.displayFont,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        height: 1.1,
        color: cs.onSurface,
      ),
    );
  }
}

/// v4 `.chip` filter row — All/Recovery/Energy/Sleep/Cold, single-select.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onTap});
  final _Filter selected;
  final ValueChanged<_Filter> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final f in _Filter.values)
          AppChip(
            label: _filterLabels[f]!,
            selected: f == selected,
            onTap: () => onTap(f),
          ),
      ],
    );
  }
}

/// v4 30-day program hero card. Mockup `.hero` with cold-shadow override:
///   heroDark gradient + `0 20px 40px -18px rgba(45,124,241,.5)` shadow.
///   Inner: `.lbl` Program + `.big` '❄️ 30-Day Cold Challenge' + bar-p 40% +
///   'Day 12 of 30' footer. (Static: program enrollment tracked separately.)
class _ProgramHero extends StatelessWidget {
  const _ProgramHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.27, -1),
          end: Alignment(0.27, 1),
          colors: [Color(0xFF12121A), Color(0xFF25252F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x802D7CF1),
            blurRadius: 40,
            offset: Offset(0, 20),
            spreadRadius: -18,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'PROGRAM',
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: Color(0xB3FFFFFF),
              height: 1.2,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '❄️ 30-Day Cold Challenge',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10),
          _ProgressBar(fraction: 0.40),
          SizedBox(height: 6),
          Text(
            'Day 12 of 30',
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xD9FFFFFF),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mockup `.bar-p` — 8px tall track + heat gradient fill at 40% width.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        height: 8,
        color: const Color(0x33FFFFFF),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0, 1),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.heat, AppColors.coral],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllProtocolsLabel extends StatelessWidget {
  const _AllProtocolsLabel();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Text(
        'All protocols',
        style: TextStyle(
          fontFamily: AppTypography.displayFont,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class _ProtocolGrid extends StatelessWidget {
  const _ProtocolGrid({required this.protocols, required this.tier, required this.onTap});
  final List<Protocol> protocols;
  final SubscriptionTier tier;
  final ValueChanged<Protocol> onTap;

  @override
  Widget build(BuildContext context) {
    // Mockup appends a Custom tile; inserted if no custom protocol in data.
    final tiles = [...protocols];
    final hasCustom = protocols.any((p) => p.isCustom);
    if (!hasCustom) tiles.add(const _CustomTileProtocol());

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        MediaQuery.paddingOf(context).bottom + 82 + 16,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) {
        final p = tiles[i];
        if (p.isCustom) {
          return _CustomTile(onTap: () => onTap(p));
        }
        return _ProtocolTile(protocol: p, tier: tier, onTap: () => onTap(p));
      },
    );
  }
}

/// Marker protocol POJO so `_ProtocolGrid` doesn't need null checks.
class _CustomTileProtocol extends Protocol {
  const _CustomTileProtocol()
      : super(
          id: '__custom__',
          name: 'Custom',
          description: 'Build your own',
          category: ProtocolCategory.custom,
          difficulty: ProtocolDifficulty.beginner,
          rounds: 1,
          phases: const [],
          isCustom: true,
        );
}

class _ProtocolTile extends StatelessWidget {
  const _ProtocolTile({required this.protocol, required this.tier, required this.onTap});
  final Protocol protocol;
  final SubscriptionTier tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final style = _categoryStyles[protocol.category.name] ??
        const _CategoryStyle(emoji: '✨', bg: Color(0xFFEEEEEE), accent: AppColors.heat);
    final isPro = protocol.isPro;
    final minutes = protocol.totalDuration.inMinutes;
    final subtitle = '${protocol.rounds}× · ${minutes}m';

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ext.lineColor),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(style.emoji, style: const TextStyle(fontSize: 18, height: 1)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    protocol.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                      height: 1.2,
                      color: cs.onSurface,
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
              if (isPro)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: AppProLockBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// v4 Custom tile — ➕ on var(--line) ink2 background.
class _CustomTile extends StatelessWidget {
  const _CustomTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ext.lineColor),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ext.lineColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '➕',
                  style: TextStyle(fontSize: 18, height: 1, color: ext.textMuted),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Custom',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  height: 1.2,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Build your own',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧊', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
