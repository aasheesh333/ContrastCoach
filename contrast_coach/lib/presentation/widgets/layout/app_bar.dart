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
  });

  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: cs.outline)),
      leading: showBackButton
          ? IconButton(
              icon: const AppIcon(LucideIcons.chevronLeft, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
