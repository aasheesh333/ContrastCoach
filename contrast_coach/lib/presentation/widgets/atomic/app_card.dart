import 'package:contrast_coach/core/constants/app_shapes.dart';
import 'package:flutter/material.dart';

enum AppCardElevation { low, medium, high }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.elevation = AppCardElevation.medium,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.radius,
  });

  final Widget child;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, defaultRadius, elev) = switch (elevation) {
      AppCardElevation.low => (cs.surface, AppShapes.cardSmall, 0.0),
      AppCardElevation.medium => (cs.surface, AppShapes.cardMedium, 1.0),
      AppCardElevation.high => (cs.surface, AppShapes.cardLarge, 3.0),
    };
    final r = radius ?? defaultRadius;

    return Material(
      color: bg,
      elevation: elev,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
