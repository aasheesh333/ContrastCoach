import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/presentation/state/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// v4 accent palette options surfaced in the picker.
/// Tapping a swatch calls [ThemeController.setAccentColor], which persists
/// via AppPreferences and triggers a live recolor of the whole app
/// (MaterialApp rebuild via `themeControllerProvider`).
const List<Color> _kAccentPalette = <Color>[
  AppColors.heat,
  AppColors.coral,
  AppColors.cold,
  AppColors.cold2,
  AppColors.purple,
  AppColors.ok,
];

const List<ThemeMode> _kThemeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.dark,
  ThemeMode.system,
];

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageTop,
            AppSpacing.pageHorizontal,
            AppSpacing.pageBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel('Accent color'),
              const SizedBox(height: AppSpacing.sm),
              _AccentPalette(
                palette: _kAccentPalette,
                selected: theme.accentColor,
                onSelect: (color) => ref
                    .read(themeControllerProvider.notifier)
                    .setAccentColor(color),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              _SectionLabel('Theme mode'),
              const SizedBox(height: AppSpacing.sm),
              _ThemeModeSelector(
                modes: _kThemeModes,
                selected: theme.themeMode,
                onSelect: (mode) => ref
                    .read(themeControllerProvider.notifier)
                    .setThemeMode(mode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _AccentPalette extends StatelessWidget {
  const _AccentPalette({
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  final List<Color> palette;
  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardSoftFor(context),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1,
        ),
        itemCount: palette.length,
        itemBuilder: (context, index) {
          final color = palette[index];
          final isSelected = color.value == selected.value;
          return GestureDetector(
            onTap: () => onSelect(color),
            behavior: HitTestBehavior.opaque,
            child: Semantics(
              label: 'Accent color ${index + 1}',
              button: true,
              selected: isSelected,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : Border.all(color: Colors.transparent, width: 3),
                  boxShadow: isSelected
                      ? [
                      BoxShadow(
                        color: color.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : const SizedBox.expand(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.modes,
    required this.selected,
    required this.onSelect,
  });

  final List<ThemeMode> modes;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelect;

  String _label(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardSoftFor(context),
      ),
      child: SegmentedButton<ThemeMode>(
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          selectedForegroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        segments: modes
            .map((mode) => ButtonSegment<ThemeMode>(
                  value: mode,
                  label: Text(_label(mode)),
                ))
            .toList(),
        selected: <ThemeMode>{selected},
        onSelectionChanged: (selection) {
          final mode = selection.first;
          onSelect(mode);
        },
        showSelectedIcon: false,
      ),
    );
  }
}
