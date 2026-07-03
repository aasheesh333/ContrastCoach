import 'dart:math' as math;
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// v4 referral code box. Matches the mockup `.refcode` token:
///   2px dashed var(--heat) border, radius 14, padding 14,
///   JetBrains Mono-equivalent monospace, 26px w500 ls 2px, heat text,
///   centered. Used inside the referral CTA card.
class AppRefCode extends StatelessWidget {
  const AppRefCode({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      foregroundDecoration: _DashedBorderDecoration(
        color: AppColors.heat,
        width: 2,
        radius: 14,
      ),
      child: Center(
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontFamilyFallback: ['RobotoMono', 'monospace'],
            fontSize: 26,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            color: AppColors.heat,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderDecoration extends Decoration {
  const _DashedBorderDecoration({
    required this.color,
    required this.width,
    required this.radius,
  });
  final Color color;
  final double width;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _DashedBorderPainter(this, onChanged);
}

class _DashedBorderPainter extends BoxPainter {
  _DashedBorderPainter(this._decoration, VoidCallback? onChanged)
      : super(onChanged);
  final _DashedBorderDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final rrect = RRect.fromRectAndRadius(
      offset & size,
      Radius.circular(_decoration.radius),
    ).deflate(_decoration.width / 2);

    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = _decoration.color
      ..strokeWidth = _decoration.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashWidth = 6.0;
    const dashGap = 4.0;

    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = math.min(dist + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      other is _DashedBorderPainter &&
      other._decoration.color == _decoration.color &&
      other._decoration.width == _decoration.width &&
      other._decoration.radius == _decoration.radius;

  @override
  int get hashCode => Object.hash(
      _decoration.color, _decoration.width, _decoration.radius);
}
