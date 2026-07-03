import 'package:flutter/material.dart';

class BodyGlow extends StatelessWidget {
  const BodyGlow({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(brightness: Theme.of(context).brightness),
      child: child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter({required this.brightness});
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = brightness == Brightness.dark;
    final basePaint = Paint()
      ..color = isDark ? const Color(0xFF0A0B0F) : const Color(0xFFECEEF3);
    canvas.drawRect(Offset.zero & size, basePaint);

    final warmPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-1.0, -1.0),
        radius: 0.9,
        colors: [
          const Color(0x66FFE1D0),
          const Color(0x00FFE1D0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, warmPaint);

    final coolPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, -1.0),
        radius: 0.9,
        colors: [
          const Color(0x66D4E4FF),
          const Color(0x00D4E4FF),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, coolPaint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.brightness != brightness;
}
