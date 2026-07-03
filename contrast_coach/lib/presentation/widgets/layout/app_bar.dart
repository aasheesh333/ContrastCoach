import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final lineColor =
        Theme.of(context).extension<AppColorsExtension>()!.lineColor;
    return AppBar(
      title: Text(
        title,
        style: AppTypography.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? Semantics(
              label: 'Back',
              button: true,
              child: Material(
                color: Colors.transparent,
                shape: CircleBorder(side: BorderSide(color: lineColor, width: 1)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(child: AppIcon(LucideIcons.chevronLeft, size: 20)),
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
