import 'dart:async';

import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:flutter/material.dart';

class ContrastCoachApp extends StatefulWidget {
  const ContrastCoachApp({super.key});

  @override
  State<ContrastCoachApp> createState() => _ContrastCoachAppState();
}

class _ContrastCoachAppState extends State<ContrastCoachApp> {
  StreamSubscription<dynamic>? _authSubscription;
  late bool _isOnboarded;
  late bool _isAuthed;

  @override
  void initState() {
    super.initState();
    _isOnboarded = AppPreferences.isOnboardingComplete;
    _isAuthed = FirebaseAuthNullableProxy.tryGet()?.currentUser != null;
    AppPreferences.changes.addListener(_handlePreferenceChange);
    if (!AppPreferences.isInitialized) {
      unawaited(_loadPreferences());
    }
    _authSubscription = FirebaseAuthNullableProxy.tryGet()?.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() => _isAuthed = user != null);
    });
  }

  Future<void> _loadPreferences() async {
    try {
      await AppPreferences.init();
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() => _isOnboarded = AppPreferences.isOnboardingComplete);
  }

  void _handlePreferenceChange() {
    if (!mounted) return;
    setState(() => _isOnboarded = AppPreferences.isOnboardingComplete);
  }

  @override
  void dispose() {
    AppPreferences.changes.removeListener(_handlePreferenceChange);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ContrastCoach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: AppPreferences.themeModeValue,
      routerConfig: AppRouter.build(isOnboarded: _isOnboarded, isAuthed: _isAuthed),
    );
  }
}
