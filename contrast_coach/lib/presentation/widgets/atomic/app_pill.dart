import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// v4 pill. Matches the mockup `.pill` token (used on dark hero cards):
///   background `rgba(255,255,255,.14)`, border 1px `rgba(255,255,255,.16)`,
///   radius 11, padding 5/9, font 11 / w600, white text.
///   Differs from [AppChip] (which is a light, bordered surface chip and is
///   used on light backgrounds) — [AppPill] is for dark surfaces only.
class AppPill extends StatelessWidget {
  const AppPill({super.key, required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x24FFFFFF),
        border: Border.all(color: const Color(0x29FFFFFF), width: 1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              letterSpacing: 0,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
