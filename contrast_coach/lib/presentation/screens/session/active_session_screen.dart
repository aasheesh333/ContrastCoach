import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:flutter/material.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Duration _remaining = const Duration(minutes: 15);
  bool _paused = false;
  int _currentRound = 1;
  final int _totalRounds = 3;
  final String _phase = 'Sauna';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SessionTimer(
                phaseLabel: _phase,
                remaining: _remaining,
                currentRound: _currentRound,
                totalRounds: _totalRounds,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Say 'next phase' to continue",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _paused ? 'Resume' : 'Pause',
                    onPressed: () => setState(() => _paused = !_paused),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
