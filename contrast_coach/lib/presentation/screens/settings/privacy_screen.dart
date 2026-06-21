import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _analytics = AppPreferences.analyticsEnabled;

  Future<void> _setAnalytics(bool value) async {
    await AppPreferences.setAnalyticsEnabled(value);
    await AnalyticsApi.syncCollectionEnabled();
    if (!mounted) return;
    setState(() => _analytics = value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppCard.section(child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: cs.secondary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.analytics_outlined, color: cs.secondary, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Analytics', style: cs.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text('Helps us improve the app. No personal data.', style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ])),
        AppSwitch(value: _analytics, onChanged: _setAnalytics),
      ])),
      const SizedBox(height: AppSpacing.lg),
      Container(padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.5), borderRadius: BorderRadius.circular(20)), child: Text('Your health data never leaves your device. Disconnect Health Connect to erase it all.', style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurface, height: 1.5))),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}
