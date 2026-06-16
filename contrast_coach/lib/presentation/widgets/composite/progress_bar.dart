import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({super.key, required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : current / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 4,
        color: Colors.white.withOpacity(0.25),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.contrastHorizontal,
            ),
          ),
        ),
      ),
    );
  }
}
