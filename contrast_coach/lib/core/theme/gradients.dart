import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand gradients and reusable decorative widgets.
class AppGradients {
  const AppGradients._();

  /// Orange → coral (paywall, paywall background)
  static const LinearGradient heat = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandWarm, AppColors.brandCoral],
  );

  /// Orange → blue (active session, hero progress, insight hero)
  static const LinearGradient contrast = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandWarm, AppColors.brandCool],
  );

  /// Orange → blue, horizontal (progress bar)
  static const LinearGradient contrastHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandWarm, AppColors.brandCool],
  );

  /// Soft warm beige vertical (home background hint)
  static const LinearGradient warmBeige = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.warmBeige, AppColors.offWhite],
  );

  /// Coral pop (premium badges)
  static const LinearGradient coralPop = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandCoral, AppColors.brandCoralPop],
  );
}

/// Decorative card with soft elevation. Used for hero, goal, insight cards.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 20,
    this.color,
    this.onTap,
    this.elevation = 2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.surface;
    return Material(
      color: bg,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.05),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
