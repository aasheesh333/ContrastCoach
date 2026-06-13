import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: cs.onSurface,
        inactiveTrackColor: cs.outline,
        thumbColor: cs.onSurface,
        overlayColor: cs.onSurface.withOpacity(0.1),
        valueIndicatorColor: cs.onSurface,
        valueIndicatorTextStyle: TextStyle(color: cs.surface),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
