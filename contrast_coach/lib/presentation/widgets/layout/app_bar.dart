import 'package:contrast_coach/core/constants/app_typography.dart';
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
              child: IconButton(
                icon: const AppIcon(LucideIcons.chevronLeft, size: 24),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
