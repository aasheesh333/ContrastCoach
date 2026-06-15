import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:flutter/material.dart';

class ContrastCoachApp extends StatelessWidget {
  const ContrastCoachApp({super.key, this.isOnboarded = false, this.isAuthed = false});
  final bool isOnboarded;
  final bool isAuthed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ContrastCoach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.build(isOnboarded: isOnboarded, isAuthed: isAuthed),
    );
  }
}
