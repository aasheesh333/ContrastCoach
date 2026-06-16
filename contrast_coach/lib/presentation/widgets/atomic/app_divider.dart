import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 0, this.endIndent = 0, this.thickness = 1, this.color});
  final double indent;
  final double endIndent;
  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? Theme.of(context).colorScheme.outline.withOpacity(0.5),
    );
  }
}
