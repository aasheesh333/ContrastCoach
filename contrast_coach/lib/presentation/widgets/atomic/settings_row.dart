import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.label, this.icon, this.iconColor, this.trailing, this.location, this.onTap});
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final String? location;
  final VoidCallback? onTap;
  bool get _tappable => onTap != null || location != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(color: Colors.transparent, child: InkWell(onTap: _tappable ? (onTap ?? () => context.push(location!)) : null, child: Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2), child: Row(children: [
      if (icon != null) ...[Container(width: 32, height: 32, decoration: BoxDecoration(color: (iconColor ?? cs.primary).withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor ?? cs.primary, size: 16)), const SizedBox(width: 14)],
      Expanded(child: Text(label, style: cs.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface))),
      trailing ?? Icon(LucideIcons.chevronRight, size: 18, color: cs.outline),
    ]))));
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.15)));
}
