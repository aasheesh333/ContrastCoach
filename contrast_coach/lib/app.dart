import 'dart:async';

import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContrastCoachApp extends StatefulWidget {
  const ContrastCoachApp({super.key});

  @override
  State<ContrastCoachApp> createState() => _ContrastCoachAppState();
}

class _ContrastCoachAppState extends State<ContrastCoachApp> {
  StreamSubscription<dynamic>? _authSubscription;
  late bool _isOnboarded;
  late bool _isAuthed;
  late final GoRouterRefreshNotifier _refreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _isOnboarded = AppPreferences.isOnboardingComplete;
    _isAuthed = FirebaseAuthNullableProxy.tryGet()?.currentUser != null;
    _refreshNotifier = GoRouterRefreshNotifier();
    _refreshNotifier.notify();
    _router = AppRouter.build(
      isOnboarded: _isOnboarded,
      isAuthed: _isAuthed,
      refreshListenable: _refreshNotifier,
    );
    AppPreferences.changes.addListener(_handlePreferenceChange);
    if (!AppPreferences.isInitialized) {
      unawaited(_loadPreferences());
    }
    _authSubscription = FirebaseAuthNullableProxy.tryGet()?.authStateChanges().listen((user) {
      if (!mounted) return;
      final newAuthed = user != null;
      if (_isAuthed != newAuthed) {
        _isAuthed = newAuthed;
        _refreshNotifier.notify();
      }
    });
  }

  Future<void> _loadPreferences() async {
    try {
      await AppPreferences.init();
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final newOnboarded = AppPreferences.isOnboardingComplete;
    if (_isOnboarded != newOnboarded) {
      _isOnboarded = newOnboarded;
      _refreshNotifier.notify();
    }
  }

  void _handlePreferenceChange() {
    if (!mounted) return;
    final newOnboarded = AppPreferences.isOnboardingComplete;
    if (_isOnboarded != newOnboarded) {
      _isOnboarded = newOnboarded;
      _refreshNotifier.notify();
    }
  }

  @override
  void dispose() {
    AppPreferences.changes.removeListener(_handlePreferenceChange);
    _authSubscription?.cancel();
    _refreshNotifier.dispose();
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
      routerConfig: _router,
    );
  }
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
