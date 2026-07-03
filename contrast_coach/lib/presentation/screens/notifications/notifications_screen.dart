import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Notifications — mockup `#notif`.
///
/// `.appbar` "Notifications" h2.
/// `.card.list` of 6 `.set` rows: Daily reminder (on/.sw),
///   Reminder time "7:00 AM" (ink2 label, ink-bold value),
///   Streak at risk (on), Hydration nudges (off), Challenge updates (on),
///   Product news (off).
/// `.sec-t` "Active days" 13 w800.
/// 7 chips `.chip` Mon..Sun, M-F `.on`.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _daily = true;
  bool _streakRisk = true;
  bool _hydration = false;
  bool _challengeUpdates = true;
  bool _productNews = false;
  final Set<String> _activeDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};

  static const _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar:
          const ContrastAppBar(title: 'Notifications', showBackButton: true),
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
                    _ToggleRow(
                      emoji: '⏰',
                      label: 'Daily reminder',
                      value: _daily,
                      onChanged: (v) => setState(() => _daily = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    const _ValueRow(
                        emoji: '',
                        label: 'Reminder time',
                        value: '7:00 AM',
                        labelMuted: true),
                    Container(height: 1, color: ext.lineColor),
                    _ToggleRow(
                      emoji: '🔥',
                      label: 'Streak at risk',
                      value: _streakRisk,
                      onChanged: (v) => setState(() => _streakRisk = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _ToggleRow(
                      emoji: '💧',
                      label: 'Hydration nudges',
                      value: _hydration,
                      onChanged: (v) => setState(() => _hydration = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _ToggleRow(
                      emoji: '🏆',
                      label: 'Challenge updates',
                      value: _challengeUpdates,
                      onChanged: (v) => setState(() => _challengeUpdates = v),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _ToggleRow(
                      emoji: '📣',
                      label: 'Product news',
                      value: _productNews,
                      onChanged: (v) => setState(() => _productNews = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 0, 2, 10),
                child: Text(
                  'Active days',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _allDays)
                    AppChip(
                      label: d,
                      selected: _activeDays.contains(d),
                      onTap: () => setState(() {
                        if (_activeDays.contains(d)) {
                          _activeDays.remove(d);
                        } else {
                          _activeDays.add(d);
                        }
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
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
          if (emoji.isNotEmpty) ...[
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 10),
          ],
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

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.emoji,
    required this.label,
    required this.value,
    this.labelMuted = false,
  });
  final String emoji;
  final String label;
  final String value;
  final bool labelMuted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (emoji.isNotEmpty) ...[
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelMuted ? cs.onSurfaceVariant : null,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
