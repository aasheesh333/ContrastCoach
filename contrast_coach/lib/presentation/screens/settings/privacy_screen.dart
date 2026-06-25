import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/remote/firebase/analytics_api.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.cardSoftFor(context),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.brandCool.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.analytics_outlined, color: AppColors.brandCool, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                             'Analytics',
                             style: TextStyle(
                               fontFamily: 'PlusJakartaSans',
                               fontSize: 16,
                               fontWeight: FontWeight.w700,
                               color: Theme.of(context).colorScheme.onSurface,
                             ),
                          ),
                          SizedBox(height: 2),
                           Text(
                             'Helps us improve the app. No personal data.',
                             style: TextStyle(
                               fontFamily: 'PlusJakartaSans',
                               fontSize: 13,
                               color: Theme.of(context).colorScheme.onSurfaceVariant,
                             ),
                          ),
                        ],
                      ),
                    ),
                    AppSwitch(
                      value: _analytics,
                      onChanged: (value) => _setAnalytics(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Your health data never leaves your device. Disconnect Health Connect to erase it all.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
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
