import 'package:flutter/material.dart';

enum AppCardElevation { low, medium, high }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.elevation = AppCardElevation.low,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, radius) = switch (elevation) {
      AppCardElevation.low => (cs.surface, 12.0),
      AppCardElevation.medium => (cs.surface, 16.0),
      AppCardElevation.high => (cs.surface, 28.0),
    };

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
