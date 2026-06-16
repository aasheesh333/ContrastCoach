import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onSelected,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onSelected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = accent ?? AppColors.brandWarm;
    final bg = selected ? accentColor : Colors.transparent;
    final fg = selected ? AppColors.white : cs.onSurface;
    final borderColor = selected ? accentColor : cs.outline;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: borderColor, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap ?? onSelected,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
