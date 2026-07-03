import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Brand gradients and reusable decorative widgets.
class AppGradients {
  const AppGradients._();

  /// Heat gradient (heat → coral) at 120deg. Matches mockup `.btn` for any
  /// element that needs a generic heat fill (e.g. score hero on dark surface).
  static const LinearGradient heat = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [AppColors.heat, AppColors.coral],
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
  @Deprecated('Use v4 tokens')
  static const LinearGradient warmBeige = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.warmBeige, AppColors.offWhite],
  );

  /// Coral pop (premium badges)
  @Deprecated('Use v4 tokens')
  static const LinearGradient coralPop = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandCoral, AppColors.brandCoralPop],
  );

  /// Splash background: heat → purple → cold (~160deg).
  static const LinearGradient splashBg = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [AppColors.heat, Color(0xFF7A2AA8), AppColors.cold],
    stops: [0.0, 0.58, 1.0],
  );

  /// Dark hero: near-black diagonal 140deg — `linear-gradient(140deg,#12121a,#25252f)`.
  static const LinearGradient heroDark = LinearGradient(
    begin: Alignment(-0.27, -1),
    end: Alignment(0.27, 1),
    colors: [Color(0xFF12121A), Color(0xFF25252F)],
  );

  /// Primary CTA button: heat → coral (~120deg).
  static const LinearGradient btnPrimary = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [AppColors.heat, AppColors.coral],
  );

  /// Cold CTA button: cold → cold2 (~120deg).
  static const LinearGradient btnCold = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [AppColors.cold, AppColors.cold2],
  );

  /// Delete button: error → warm red (~120deg).
  static const LinearGradient btnDelete = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [AppColors.error, Color(0xFFFF6B68)],
  );

  /// Warm session radial: warm ember top-center → near-black base.
  static const RadialGradient sessionWarm = RadialGradient(
    center: Alignment(0.5, 0.0),
    focal: Alignment(0.5, 0.0),
    focalRadius: 0.8,
    radius: 1.2,
    colors: [Color(0xFF7A2A0E), AppColors.lightInk],
  );

  /// Cold session radial: cold ember top-center → near-black base.
  static const RadialGradient sessionCold = RadialGradient(
    center: Alignment(0.5, 0.0),
    focal: Alignment(0.5, 0.0),
    focalRadius: 0.8,
    radius: 1.2,
    colors: [Color(0xFF0D3A7A), AppColors.lightInk],
  );

  /// Score text gradient for ShaderMask: heat → cold horizontal.
  static const LinearGradient scoreText = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.heat, AppColors.cold],
  );

  /// Score text on share card — heat → cold2 (matches the mockup
  /// `linear-gradient(120deg,var(--heat),var(--cold2))` used on share PNG).
  static const LinearGradient scoreTextShare = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [AppColors.heat, AppColors.cold2],
  );

  /// Share card background — near-black with warm ember bottom:
  /// mockup `linear-gradient(160deg,#12121a,#3a1e12)`.
  static const LinearGradient shareCard = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [Color(0xFF12121A), Color(0xFF3A1E12)],
  );

  /// Breathwork view background — deep night-blue to near-black:
  /// mockup `linear-gradient(160deg,#0a2a5c,#0c0c0e)`.
  static const LinearGradient breathwork = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [Color(0xFF0A2A5C), Color(0xFF0C0C0E)],
  );

  /// Body glow approximation: warm tint → base → cool tint across the top.
  static const LinearGradient bodyGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: [Color(0x80FFE1D0), Color(0xFFECEEF3), Color(0x80D4E4FF)],
    stops: [0.0, 0.5, 1.0],
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
