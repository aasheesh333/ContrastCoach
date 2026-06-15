import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, tertiary, text }
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
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || isLoading;

    final (Color bg, Color fg, BorderSide? border) = switch (variant) {
      AppButtonVariant.primary => (cs.onSurface, cs.surface, null),
      AppButtonVariant.secondary => (cs.surface, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.tertiary => (Colors.transparent, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.text => (Colors.transparent, cs.onSurface, null),
    };

    final fgEffective = isDisabled ? cs.onSurfaceVariant : fg;

    return SizedBox(
      height: size == AppButtonSize.large ? 88 : 48,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgEffective),
                    ),
                  )
                else ...[
                  if (leadingIcon != null) ...[
                    AppIcon(leadingIcon!, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fgEffective),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    AppIcon(trailingIcon!, size: 18),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
