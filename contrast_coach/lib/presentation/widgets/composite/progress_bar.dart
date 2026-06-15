import 'package:flutter/material.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({super.key, required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fraction = total == 0 ? 0.0 : current / total;
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: fraction,
        backgroundColor: cs.outline,
        valueColor: AlwaysStoppedAnimation<Color>(cs.onSurface),
      ),
    );
  }
}
