import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Per-category emoji used in the Explore protocol grid (spec §2.4).
const Map<String, String> _categoryEmoji = {
  'energy': '🔋',
  'sleep': '🌙',
  'recovery': '🧊',
  'immunity': '🛡️',
};

/// EXPLORE screen (spec §3.2 row 2).
/// Renders a 2-column emoji grid of all protocols sourced from the static
/// `assets/protocols.json` bundle via [ProtocolRepositoryImpl.getAll].
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<Result<List<Protocol>, AppException>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = ProtocolRepositoryImpl().getAll();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _HeroHeader(),
          Expanded(
            child: FutureBuilder<Result<List<Protocol>, AppException>>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final result = snapshot.data;
                if (result == null) {
                  return const _EmptyState(text: 'No protocols available.');
                }
                return result.fold(
                  (err) => _EmptyState(text: err.message),
                  (protocols) => protocols.isEmpty
                      ? const _EmptyState(text: 'No protocols available.')
                      : _ProtocolGrid(protocols: protocols),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Heat-tinted hero strip with the screen title, using the v4 splash gradient
/// as a background band (spec §3.2: v4 tokens + heat accent).
class _HeroHeader extends StatelessWidget {
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
        children: const [
          Text(
            'Explore',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a protocol. Tap to start.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolGrid extends StatelessWidget {
  const _ProtocolGrid({required this.protocols});
  final List<Protocol> protocols;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.pageBottom,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.86,
      ),
      itemCount: protocols.length,
      itemBuilder: (context, index) => _ProtocolTile(
        protocol: protocols[index],
      ),
    );
  }
}

class _ProtocolTile extends StatelessWidget {
  const _ProtocolTile({required this.protocol});
  final Protocol protocol;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final emoji = _categoryEmoji[protocol.category.name] ?? '补水';
    final isPro = protocol.isPro;
    final tagColor = isPro ? AppColors.heat : AppColors.cold;
    final tagLabel = isPro ? 'Pro' : 'Free';
    final difficultyLabel = _difficultyLabel(protocol.difficulty);

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/session/${protocol.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ext.lineColor),
            boxShadow: AppShadows.cardSoftFor(context),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 30)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tagLabel,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: tagColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                protocol.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                difficultyLabel,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ext.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(ProtocolDifficulty d) {
    switch (d) {
      case ProtocolDifficulty.beginner:
        return 'Beginner';
      case ProtocolDifficulty.intermediate:
        return 'Intermediate';
      case ProtocolDifficulty.advanced:
        return 'Advanced';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ext.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
