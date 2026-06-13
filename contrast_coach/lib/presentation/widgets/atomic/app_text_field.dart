import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
    this.errorText,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onChanged: onChanged,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: cs.outline)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.onSurface, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
