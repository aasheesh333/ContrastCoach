import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// v4-exact brand gradients (runbook §2.4).
///
/// Angles preserved from the CSS prototype:
///   - 120° linear (buttons, contrast horizontal)
///   - 140° linear (hero readiness card)
///   - 160° linear (splash + onboarding background)
///   - radial (active-session warm/cold, app body glow)
///
/// Flutter has no direct "N-degree" API, so linear-gradient angles are
/// approximated via begin/end alignments picked from unit-circle:
///   120° ≈ topLeft → bottomRight (shifted right)
///   140° ≈ topLeft → bottomRight
///   160° ≈ topCenter → bottomCenter (steep diagonal)
class AppGradients {
  const AppGradients._();

  // ── Linear ──────────────────────────────────────────────────────────

  /// Primary button — linear-gradient(120°, --heat, --coral).
  static const LinearGradient heatButton = LinearGradient(
    begin: Alignment(-0.9, -0.6),
    end: Alignment(0.9, 0.6),
    colors: [AppColors.brandWarm, AppColors.brandCoral],
  );

  /// Cold button — linear-gradient(120°, --cold, --cold2).
  static const LinearGradient coldButton = LinearGradient(
    begin: Alignment(-0.9, -0.6),
    end: Alignment(0.9, 0.6),
    colors: [AppColors.brandCool, AppColors.brandCool2],
  );

  /// Splash + onboarding — linear-gradient(160°, #FF6B35, #7A2AA8 58%, #2D7CF1).
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.58, 1.0],
    colors: [
      AppColors.brandWarm,
      Color(0xFF7A2AA8),
      AppColors.brandCool,
    ],
  );

  /// Hero / readiness card — linear-gradient(140°, #12121a, #25252f).
  static const LinearGradient heroReadiness = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12121A), Color(0xFF25252F)],
  );

  /// Recovery score number — heat→cold text gradient.
  static const LinearGradient recoveryScoreText = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandWarm, AppColors.brandCool],
  );

  // ── Legacy convenience aliases (kept to avoid churn across 37 callers) ──

  /// Vertical warm→coral. Alias of [heatButton] for legacy paywall code.
  static const LinearGradient heat = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandWarm, AppColors.brandCoral],
  );

  /// Vertical warm→cool. Used by active-session progress, insight hero.
  static const LinearGradient contrast = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.brandWarm, AppColors.brandCool],
  );

  /// Horizontal warm→cool. Same intent as [recoveryScoreText] for solid fills.
  static const LinearGradient contrastHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandWarm, AppColors.brandCool],
  );

  /// Soft warm beige vertical (home background hint).
  static const LinearGradient warmBeige = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.warmBeige, AppColors.offWhite],
  );

  /// Coral pop (premium badges).
  static const LinearGradient coralPop = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandCoral, AppColors.brandCoralPop],
  );

  // ── Radial ──────────────────────────────────────────────────────────

  /// Active session — warm phase.
  /// radial-gradient(120% 80% at 50% 0%, #7a2a0e, #0c0c0e)
  static const RadialGradient activeSessionWarm = RadialGradient(
    center: Alignment(0.0, -1.0),
    radius: 1.2,
    colors: [Color(0xFF7A2A0E), Color(0xFF0C0C0E)],
  );

  /// Active session — cold phase.
  /// radial-gradient(120% 80% at 50% 0%, #0d3a7a, #0c0c0e)
  static const RadialGradient activeSessionCold = RadialGradient(
    center: Alignment(0.0, -1.0),
    radius: 1.2,
    colors: [Color(0xFF0D3A7A), Color(0xFF0C0C0E)],
  );

  /// App body glow — radial #ffe1d0 (top-left) + #d4e4ff (top-right)
  /// over base #eceef3. Consumers should stack two [RadialGradient]s
  /// via a `Stack` since Flutter renders one gradient per decoration.
  static const RadialGradient bodyGlowWarm = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.4,
    colors: [Color(0xFFFFE1D0), Color(0x00FFE1D0)],
  );

  static const RadialGradient bodyGlowCool = RadialGradient(
    center: Alignment(1.0, -1.0),
    radius: 1.4,
    colors: [Color(0xFFD4E4FF), Color(0x00D4E4FF)],
  );

  /// Base color under [bodyGlowWarm] + [bodyGlowCool].
  static const Color bodyGlowBase = Color(0xFFECEEF3);
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
