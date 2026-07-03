import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// v4 app bar. Matches the mockup `.appbar` token:
///   h2 19px weight 800 letter-spacing -.4
///   ‹ back button 36×36, radius 12, 1px var(--line) border, var(--card) bg,
///   18px content (`‹`).
class ContrastAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContrastAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton = false,
    this.onBack,
    this.backgroundColor,
  });

  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).extension<AppColorsExtension>()!.lineColor;
    final cardColor = Theme.of(context).colorScheme.surface;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Semantics(
                label: 'Back',
                button: true,
                child: Material(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: lineColor, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          '‹',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
