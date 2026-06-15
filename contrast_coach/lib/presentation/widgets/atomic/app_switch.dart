import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: cs.onSurface,
      activeTrackColor: cs.onSurface.withOpacity(0.5),
      inactiveThumbColor: cs.onSurfaceVariant,
      inactiveTrackColor: cs.surfaceContainerHigh,
      trackOutlineColor: WidgetStateProperty.all(cs.outline),
    );
  }
}
