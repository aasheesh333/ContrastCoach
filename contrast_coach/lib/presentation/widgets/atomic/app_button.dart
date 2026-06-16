import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, tertiary, text, warm, cool }
enum AppButtonSize { standard, large }

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
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || isLoading;

    final (Color bg, Color fg, BorderSide? border) = switch (variant) {
      AppButtonVariant.primary => (cs.onSurface, cs.surface, null),
      AppButtonVariant.warm => (AppColors.brandWarm, AppColors.white, null),
      AppButtonVariant.cool => (AppColors.brandCool, AppColors.white, null),
      AppButtonVariant.secondary => (cs.surface, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.tertiary => (Colors.transparent, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.text => (Colors.transparent, cs.onSurface, null),
    };

    final fgEffective = isDisabled ? cs.onSurfaceVariant : fg;
    final bgEffective = isDisabled
        ? cs.surfaceContainerHigh
        : bg;

    final height = size == AppButtonSize.large ? 72 : 56;

    final child = Material(
      color: bgEffective,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: border ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fgEffective,
                        fontWeight: FontWeight.w600,
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
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
