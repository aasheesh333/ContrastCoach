import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.activeColor,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.brandWarm;
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: active,
        inactiveTrackColor: active.withOpacity(0.18),
        thumbColor: active,
        overlayColor: active.withOpacity(0.12),
        valueIndicatorColor: AppColors.charcoal,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.white),
        showValueIndicator: ShowValueIndicator.never,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
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
