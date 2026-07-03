import 'dart:async';

import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/composite/breathing_orb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 Breathwork screen — mockup `#breath`.
///
/// Background: `linear-gradient(160deg,#0a2a5c,#0c0c0e)` ([AppGradients.breathwork]).
/// 170px breathing orb ([BreathingOrb]) with `box-shadow:0 0 60px rgba(45,124,241,.6)`.
/// State text `.bstate` "INHALE" / "HOLD" / "EXHALE" — 22px w800 ls 1px white.
/// "BOX BREATHING" tiny label 13px w800 ls 3px opacity .7 white.
/// Subtext "Round 2 of 5 · tap anywhere to pause" 13 w600 opacity .6 white.
/// Top-right `.exit` ✕ 34×34 white-14% bg 50%-radius.
class BreathworkScreen extends StatefulWidget {
  const BreathworkScreen({super.key});

  @override
  State<BreathworkScreen> createState() => _BreathworkScreenState();
}

class _BreathworkScreenState extends State<BreathworkScreen> {
  static const _sequence = ['INHALE', 'HOLD', 'EXHALE', 'HOLD'];
  int _phaseIndex = 0;
  int _round = 1;
  final int _rounds = 5;
  bool _paused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _phaseIndex = (_phaseIndex + 1) % _sequence.length;
        if (_phaseIndex == 0) {
          _round = (_round % _rounds) + 1;
        }
      });
    });
  }

  void _togglePause() {
    if (_paused) {
      _paused = false;
      _startTimer();
    } else {
      _paused = true;
      _timer?.cancel();
      _timer = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _togglePause,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.breathwork),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 12,
                  right: 18,
                  child: _ExitButton(onClose: () => context.pop()),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BOX BREATHING',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const BreathingOrb(enabled: true),
                      const SizedBox(height: 24),
                      BreathStateLabel(state: _sequence[_phaseIndex]),
                      const SizedBox(height: 8),
                      Text(
                        _paused
                            ? 'Paused · tap anywhere to resume'
                            : 'Round $_round of $_rounds · tap anywhere to pause',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0x99FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x24FFFFFF),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onClose,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Text(
              '✕',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
