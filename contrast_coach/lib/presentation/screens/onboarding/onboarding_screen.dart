import 'dart:async';

import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Drift settings key for the timestamp at which the user acknowledged the
/// medical disclaimer during onboarding. Runbook §3.2.
const String kDisclaimerAcceptedAtKey = 'disclaimer_accepted_at';

Future<void> _persistDisclaimerAccepted() async {
  try {
    final db = await DatabaseProvider.instance();
    final now = DateTime.now().toUtc();
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            keyField: kDisclaimerAcceptedAtKey,
            value: now.toIso8601String(),
            updatedAt: now,
          ),
        );
  } catch (_) {
    // Non-fatal.
  }
}

/// v4 onboarding — three-slide gradient hero matching the v4 design system
/// prototype (heat → purple → cold gradient, giant type, page dots, white CTA).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _step = 0;
  bool _saving = false;
  bool _disclaimerAcknowledged = false;

  static const List<_Slide> _slides = <_Slide>[
    _Slide(
      title: 'Heat.\nCold.\nRecover smarter.',
      body:
          'Track sauna + cold plunge, get an HRV-powered recovery score, and build a streak that sticks.',
    ),
    _Slide(
      title: 'Guided\nsessions\nthat adapt.',
      body:
          'Standard, Energy, Sleep, Immunity — protocols tuned to how you feel today, not a generic script.',
    ),
    _Slide(
      title: 'Private\nby default.',
      body:
          'Your data stays on device with SQLCipher encryption. Cloud sync is opt-in and never automatic.',
    ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_saving) return;
    if (_step < _slides.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    // Last slide → show medical disclaimer before completing.
    if (!_disclaimerAcknowledged) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MedicalDisclaimerDialog(
          onAcknowledge: () {
            Navigator.of(context).pop();
            _disclaimerAcknowledged = true;
            unawaited(_persistDisclaimerAccepted());
            _complete();
          },
        ),
      );
      return;
    }
    await _complete();
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    final ok = await AppPreferences.setOnboardingComplete(true);
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Please try again.')),
      );
      return;
    }
    context.go('/sign-in');
  }

  void _skip() {
    if (_saving) return;
    // Skip jumps straight to disclaimer + completion.
    _pc.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: <double>[0.0, 0.6, 1.0],
            colors: <Color>[
              Color(0xFFFF6B35), // --heat
              Color(0xFF7A2AA8), // mid purple
              Color(0xFF2D7CF1), // --cold
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              // Skip button (top-right)
              Positioned(
                top: 8,
                right: 8,
                child: TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.85),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              // Slides + bottom controls
              Column(
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      controller: _pc,
                      onPageChanged: (i) => setState(() => _step = i),
                      itemCount: _slides.length,
                      itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      26,
                      0,
                      26,
                      24 + media.padding.bottom * 0.2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _PageDots(active: _step, total: _slides.length),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _saving ? null : _next,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFFF6B35),
                              disabledBackgroundColor:
                                  Colors.white.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Color(0xFFFF6B35),
                                    ),
                                  )
                                : Text(
                                    _step == _slides.length - 1
                                        ? 'Get started  →'
                                        : 'Continue  →',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.title, required this.body});
  final String title;
  final String body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            slide.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.active, required this.total});
  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(total, (i) {
        final bool on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 6),
          width: on ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
