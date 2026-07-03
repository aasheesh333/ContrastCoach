import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_motion.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// v4 design-system switch. Matches the mockup `.sw` token:
///   46×28 rail (radius 16), ink3/line inactive bg, heat active bg,
///   22×22 white circular thumb that slides left-3 → left-21 with
///   `cubic-bezier(.3,1.4,.5,1)` spring overshoot, 0.2s transition.
///   Drops the stock Material `Switch` (which renders a non-spec shape).
class AppSwitch extends StatefulWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _thumbPos;
  late final Animation<double> _railColorMix;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value ? 1.0 : 0.0,
    );
    _thumbPos = Tween<double>(begin: 3.0, end: 21.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.switchThumb),
    );
    _railColorMix = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.animateTo(widget.value ? 1.0 : 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.onChanged == null) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).extension<AppColorsExtension>()!.lineColor;
    final activeColor = AppColors.heat;
    final inactiveColor = lineColor;

    final railColor = Color.lerp(
      inactiveColor,
      activeColor,
      _railColorMix.value,
    )!;

    return Semantics(
      toggled: widget.value,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: 28,
          decoration: BoxDecoration(
            color: railColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Positioned(
                    left: _thumbPos.value,
                    top: 3,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
