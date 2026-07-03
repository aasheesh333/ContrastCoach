import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_shapes.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  tertiary,
  text,
  warm,
  cool,
  ghost2,
  delete,
}

enum AppButtonSize { standard, large }

/// v4 design-system button. Matches the mockup `.btn` token:
///   radius 14, padding 15, font 15 / weight 800 / letter-spacing -.2,
///   heat→coral background with `0 14px 26px -12px var(--heat)` shadow.
/// Variants:
///   primary  — `.btn` heat gradient + heat shadow.
///   warm     — alias of primary (kept for back-compat call-sites).
///   cool     — `.btn.cold` cold gradient + cold shadow.
///   ghost2   — `.btn.ghost2` flat, ink2 text, 1px line border, no shadow.
///   secondary — surface bg, on-surface text, 1px outline border, no shadow.
///   tertiary  — transparent bg, on-surface text, 1px outline border, no shadow.
///   text      — transparent bg, on-surface text, no border, no shadow.
///   delete    — `.btn` with red `linear-gradient(120deg,#E53935,#ff6b68)` + no shadow.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.size = AppButtonSize.standard,
    this.fullWidth = false,
    this.marginTop = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonSize size;
  final bool fullWidth;
  final double marginTop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final line = Theme.of(context).colorScheme.outline;
    final isDisabled = onPressed == null || isLoading;

    final (BoxDecoration? bg, Color fg, bool hasGradient, List<BoxShadow> shadows) = switch (
      variant) {
      AppButtonVariant.primary => (
        BoxDecoration(gradient: AppGradients.btnPrimary),
        AppColors.white,
        true,
        AppShadows.buttonHeat,
      ),
      AppButtonVariant.warm => (
        BoxDecoration(gradient: AppGradients.btnPrimary),
        AppColors.white,
        true,
        AppShadows.buttonHeat,
      ),
      AppButtonVariant.cool => (
        BoxDecoration(gradient: AppGradients.btnCold),
        AppColors.white,
        true,
        AppShadows.buttonCold,
      ),
      AppButtonVariant.delete => (
        BoxDecoration(gradient: AppGradients.btnDelete),
        AppColors.white,
        true,
        const <BoxShadow>[],
      ),
      AppButtonVariant.secondary => (
        BoxDecoration(color: cs.surface),
        cs.onSurface,
        false,
        const <BoxShadow>[],
      ),
      AppButtonVariant.tertiary => (
        BoxDecoration(color: Colors.transparent),
        cs.onSurface,
        false,
        const <BoxShadow>[],
      ),
      AppButtonVariant.ghost2 => (
        BoxDecoration(color: Colors.transparent),
        cs.onSurfaceVariant,
        false,
        const <BoxShadow>[],
      ),
      AppButtonVariant.text => (
        BoxDecoration(color: Colors.transparent),
        cs.onSurface,
        false,
        const <BoxShadow>[],
      ),
    };

    final border = switch (variant) {
      AppButtonVariant.secondary ||
      AppButtonVariant.tertiary ||
      AppButtonVariant.ghost2 => BorderSide(color: line, width: 1),
      _ => BorderSide.none,
    };

    // Pull gradient + flat color separately so the disabled-state override
    // can fall back to a Color (cs.surfaceContainerHigh) without unifying the
    // static type of `bg` (BoxDecoration?) with Color (Object?).
    final Gradient? gradientBg = hasGradient ? bg?.gradient : null;
    final Color? flatColor = hasGradient ? null : (bg?.color ?? cs.surface);
    final Color? disabledFlatColor = (hasGradient || isDisabled) ? null : cs.surfaceContainerHigh;
    final Color? effectiveFlatColor = isDisabled ? disabledFlatColor : flatColor;
    final Gradient? effectiveGradient =
        (hasGradient && !isDisabled) ? gradientBg : null;
    final Color fgEffective = isDisabled ? cs.onSurfaceVariant : fg;
    final List<BoxShadow> shadowsEffective =
        isDisabled ? const <BoxShadow>[] : shadows;
    final BoxBorder? effectiveBorder = border == BorderSide.none
        ? null
        : Border.fromBorderSide(border);

    final double height = size == AppButtonSize.large ? 56 : 48;
    final double radius = AppShapes.small; // 14

    final child = DecoratedBox(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        color: effectiveFlatColor,
        borderRadius: BorderRadius.circular(radius),
        border: effectiveBorder,
        boxShadow: shadowsEffective,
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgEffective),
                    ),
                  )
                else ...[
                  if (leadingIcon != null) ...[
                    AppIcon(leadingIcon!, size: 20, color: fgEffective),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: AppTypography.titleMedium.copyWith(
                      color: fgEffective,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    AppIcon(trailingIcon!, size: 20, color: fgEffective),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final wrapped = fullWidth ? SizedBox(width: double.infinity, child: child) : child;

    if (marginTop > 0) {
      return Padding(padding: EdgeInsets.only(top: marginTop), child: wrapped);
    }
    return wrapped;
  }
}
