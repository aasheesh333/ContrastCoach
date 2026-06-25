import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
/// Single source of truth for "this user's plan" badge.
/// Replaces the hardcoded 'Free plan' string in Settings.
class PlanBadge extends StatelessWidget {
  const PlanBadge({
    super.key,
    required this.subscriptionStatus,
    this.onTap,
  });

  final String subscriptionStatus;
  final VoidCallback? onTap;

  bool get _isPro => subscriptionStatus.toLowerCase() == 'pro';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isPro ? AppColors.brandWarm : Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPro ? LucideIcons.crown : LucideIcons.sparkles,
                size: 13,
                color: _isPro ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _isPro ? 'Pro' : 'Free',
                style: AppTypography.labelMedium?.copyWith(
                  color: _isPro ? AppColors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable user avatar with initials fallback. Sized by the caller.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.photoUrl,
    this.size = 44,
  });

  final String initials;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = photoUrl != null && photoUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.brandWarm, AppColors.brandCoral],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initials(initials: initials, size: size),
              loadingBuilder: (c, w, p) =>
                  p == null ? w : _Initials(initials: initials, size: size),
            )
          : _Initials(initials: initials, size: size),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials, required this.size});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.white,
          fontSize: size * 0.40,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Time-of-day greeting (real, not from hardcoded English).
String greetingForHour(int hour) {
  if (hour < 5) return 'Resting up';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 21) return 'Good evening';
  return 'Winding down';
}

/// Maps a session's local hour to a recommended protocol ID.
String recommendedProtocolForHour(int hour) {
  if (hour >= 5 && hour < 12) return 'energy_morning';
  if (hour >= 18 || hour < 5) return 'sleep_evening';
  return 'recovery_standard';
}

/// Short, contextual header line for the home greeting.
String headerLineForHour(int hour) {
  if (hour < 5) return 'Late night. Keep it short.';
  if (hour < 12) return 'Start the day alert.';
  if (hour < 17) return 'Reset in the middle of the day.';
  if (hour < 21) return 'Wind down the right way.';
  return 'Tomorrow is a new chance.';
}
