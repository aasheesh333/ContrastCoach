import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Health Connect — mockup `#health`.
///
/// `.appbar` "Health Connect" h2.
/// Big `.card` (centered, padding 20): ❤️ 34px, "Smarter recovery score" 14? w800,
///   subtext 13 ink2, `.btn` "Connect Health Connect".
/// `.sec-t` "Permissions" 13 w800.
/// `.card.list` of 3 `.set` rows each ON: ❤️ Heart rate variability,
///   😴 Sleep, 💓 Resting heart rate.
/// Privacy footnote 11 ink3: "🔒 Processed on-device · never uploaded."
class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  bool _hrv = true;
  bool _sleep = true;
  bool _restingHr = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(
          title: 'Health Connect', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 34)),
                    const SizedBox(height: 8),
                    const Text(
                      'Smarter recovery score',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect Health Connect to factor in your HRV, sleep and resting HR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Connect Health Connect',
                      fullWidth: true,
                      marginTop: 0,
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Health Connect linked')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 10),
                child: Text(
                  'Permissions',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _PermRow(
                      emoji: '❤️',
                      label: 'Heart rate variability',
                      value: _hrv,
                      onChanged: (v) => setState(() => _hrv = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _PermRow(
                      emoji: '😴',
                      label: 'Sleep',
                      value: _sleep,
                      onChanged: (v) => setState(() => _sleep = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _PermRow(
                      emoji: '💓',
                      label: 'Resting heart rate',
                      value: _restingHr,
                      onChanged: (v) => setState(() => _restingHr = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '🔒 Processed on-device · never uploaded.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ext.textFaint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
