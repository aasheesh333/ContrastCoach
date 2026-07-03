import 'package:contrast_coach/presentation/widgets/layout/body_glow.dart';
import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: BodyGlow(child: child),
      bottomNavigationBar: ContrastBottomNav(
        currentLocation: location,
        onTap: (loc) => context.go(loc),
      ),
    );
  }
}
