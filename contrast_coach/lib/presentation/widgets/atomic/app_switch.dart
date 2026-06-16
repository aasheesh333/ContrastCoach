import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.white,
      activeTrackColor: AppColors.brandWarm,
      inactiveThumbColor: AppColors.midGray,
      inactiveTrackColor: AppColors.lightGray,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}
