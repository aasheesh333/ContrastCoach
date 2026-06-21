import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

enum AppCardElevation { flat, soft, medium, strong }

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.xl), this.radius = 20, this.elevation = AppCardElevation.soft, this.onTap, this.color, this.borderColor});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  factory AppCard.section({required Widget child, VoidCallback? onTap, Color? color, AppCardElevation elevation = AppCardElevation.soft}) =>
      AppCard(padding: const EdgeInsets.all(AppSpacing.lg), radius: 18, elevation: elevation, onTap: onTap, color: color, child: child);

  factory AppCard.compact({required Widget child, VoidCallback? onTap, Color? color}) =>
      AppCard(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md), radius: 14, elevation: AppCardElevation.flat, onTap: onTap, color: color, child: child);

  factory AppCard.clickable({required Widget child, required VoidCallback onTap, Color? color}) =>
      AppCard(padding: const EdgeInsets.all(AppSpacing.xl), elevation: AppCardElevation.soft, onTap: onTap, color: color, child: child);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.surface;
    final shadows = switch (elevation) {
      AppCardElevation.flat => <BoxShadow>[],
      AppCardElevation.soft => AppShadows.cardSoft,
      AppCardElevation.medium => AppShadows.cardMedium,
      AppCardElevation.strong => AppShadows.cardMedium,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius), border: borderColor != null ? Border.all(color: borderColor!) : null, boxShadow: shadows),
      child: Material(type: MaterialType.transparency,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, this.trailing, this.withDivider = false});
  final String label;
  final Widget? trailing;
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: AppSpacing.sectionHeaderPadding,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label.toUpperCase(), style: cs.textTheme.labelSmall?.copyWith(color: cs.outline, letterSpacing: 1.4) ?? Theme.of(context).textTheme.labelSmall),
          if (trailing != null) trailing!,
        ]),
        if (withDivider) ...[
          const SizedBox(height: AppSpacing.sm),
          Divider(color: cs.outline.withOpacity(0.3), height: 1),
        ],
      ]),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.huge), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(color: cs.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(20)), child: Icon(icon, color: cs.primary, size: 32)),
      const SizedBox(height: 20),
      Text(title, textAlign: TextAlign.center, style: cs.textTheme.headlineMedium?.copyWith(height: 1.2) ?? Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: cs.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.45) ?? Theme.of(context).textTheme.bodyMedium),
      if (action != null) ...[const SizedBox(height: 20), action!],
    ])));
  }
}
