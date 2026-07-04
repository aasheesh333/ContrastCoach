import 'dart:async';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pop;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _popScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _pop,
        curve: const Cubic(0.2, 1.3, 0.4, 1),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _pop.stop();
      });
    _pop.forward();
    _timer = Timer(const Duration(milliseconds: 1900), _routeNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pop.dispose();
    super.dispose();
  }

  Future<void> _routeNext() async {
    if (!mounted) return;
    if (!AppPreferences.isInitialized) {
      await AppPreferences.init();
    }
    if (!mounted) return;
    final onboarded = AppPreferences.isOnboardingComplete;
    if (!mounted) return;
    if (!onboarded) {
      context.go('/onboarding');
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splashBg),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _popScale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0x29FFFFFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0x4DFFFFFF),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🔥',
                      style: TextStyle(fontSize: 48, height: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ContrastCoach',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.lightInk,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Heat · Cold · Recover',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xD9FFFFFF),
                    letterSpacing: 0,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const _SlidingLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingLoader extends StatefulWidget {
  const _SlidingLoader();

  @override
  State<_SlidingLoader> createState() => _SlidingLoaderState();
}

class _SlidingLoaderState extends State<_SlidingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _slide = Tween<double>(begin: -0.4, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 120,
        height: 4,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0x40FFFFFF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedBuilder(
              animation: _slide,
              builder: (context, _) {
                return FractionallySizedBox(
                  alignment: Alignment(_slide.value * 2 - 1, 0),
                  widthFactor: 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightInk,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

