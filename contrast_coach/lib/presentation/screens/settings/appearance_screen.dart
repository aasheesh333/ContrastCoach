import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/state/theme_controller.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// v4 Appearance — mockup `#appearance`.
///
/// `.appbar` "Appearance" h2.
/// `.card.list` 2 `.set` rows: 🌙 Dark mode (off), 🧩 Match system (on).
/// `.sec-t` "Accent color".
/// 5 round 36px `.swatch`es (#FF6B35 / #2D7CF1 / #7A5BFF / #33C27F / #E5397D),
/// selected one shows white check ring.
/// `.sec-t` "Text size" + range slider 0-100.
class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  double _textSize = 50;

  static const _accentPalette = <(Color, String, Color)>[
    (Color(0xFFFF6B35), '#FF6B35', Color(0xFFFF8A65)),
    (Color(0xFF2D7CF1), '#2D7CF1', Color(0xFF5B9CFF)),
    (Color(0xFF7A5BFF), '#7A5BFF', Color(0xFF9C86FF)),
    (Color(0xFF33C27F), '#33C27F', Color(0xFF5BD69A)),
    (Color(0xFFE5397D), '#E5397D', Color(0xFFFF6BA0)),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final theme = ref.watch(themeControllerProvider);
    final isDark = theme.themeMode == ThemeMode.dark;
    final isSystem = theme.themeMode == ThemeMode.system;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(title: 'Appearance', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Text('🌙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          const Text('Dark mode',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                          const Spacer(),
                          AppSwitch(
                            value: isDark,
                            onChanged: (v) => ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(
                                    v ? ThemeMode.dark : ThemeMode.light),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Text('🧩', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          const Text('Match system',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                          const Spacer(),
                          AppSwitch(
                            value: isSystem,
                            onChanged: (v) => ref
                                .read(themeControllerProvider.notifier)
                                .setThemeMode(
                                    v ? ThemeMode.system : ThemeMode.light),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 12),
                child: Text(
                  'Accent color',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var i = 0; i < _accentPalette.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    _AccentSwatch(
                      color: _accentPalette[i].$1,
                      accentPair: _accentPalette[i].$2,
                      accentPairDark: _accentPalette[i].$3,
                      selected: theme.accentColor.value ==
                          _accentPalette[i].$1.value,
                      onTap: () {
                        ref
                            .read(themeControllerProvider.notifier)
                            .setAccentColor(_accentPalette[i].$1);
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 12),
                child: Text(
                  'Text size',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Slider(
                value: _textSize,
                min: 0,
                max: 100,
                activeColor: AppColors.heat,
                onChanged: (v) => setState(() => _textSize = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.accentPair,
    required this.accentPairDark,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String accentPair;
  final Color accentPairDark;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
