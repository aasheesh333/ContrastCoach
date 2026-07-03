import 'package:flutter/material.dart';

/// v4 breathwork orb. Matches the mockup `.orb` token:
///   170×170 circle, radial gradient
///   `radial-gradient(circle at 40% 35%,#8fc0ff,#2D7CF1 60%,#1a4fa0)`,
///   8s infinite ease-in-out breathe animation `(scale 0.65 ↔ 1.0)`,
///   glow `0 0 60px rgba(45,124,241,.6)`.
class BreathingOrb extends StatefulWidget {
  const BreathingOrb({super.key, this.enabled = true});
  final bool enabled;

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
    _scale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant BreathingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled && !_controller.isAnimating) {
        _controller.repeat();
      } else if (!widget.enabled && _controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFF8FC0FF), Color(0xFF2D7CF1), Color(0xFF1A4FA0)],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x992D7CF1),
            blurRadius: 60,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );

    if (!widget.enabled) return child;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, _) => Transform.scale(scale: _scale.value, child: child),
    );
  }
}

/// v4 breathwork state label. Matches `.bstate`:
///   22px w800 ls 1px, centered.
class BreathStateLabel extends StatelessWidget {
  const BreathStateLabel({super.key, required this.state});
  final String state;

  @override
  Widget build(BuildContext context) {
    return Text(
      state,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: Colors.white,
        height: 1.1,
      ),
    );
  }
}
