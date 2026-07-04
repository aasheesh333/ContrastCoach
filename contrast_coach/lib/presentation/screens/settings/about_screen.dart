import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = '${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'About', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero
              Center(
                child: Column(
                  children: [
                    Semantics(
                      label: 'ContrastCoach app icon',
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.heat, AppColors.coral],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.thermometer, color: AppColors.white, size: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_appVersion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Version $_appVersion',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.cardSoftFor(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.heat.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const AppIcon(
                            LucideIcons.shield,
                            size: 16,
                            color: AppColors.heat,
                          ),
                        ),
                        const SizedBox(width: 12),
                         Text(
                           'MEDICAL DISCLAIMER',
                           style: TextStyle(
                             fontFamily: 'PlusJakartaSans',
                             fontSize: 11,
                             fontWeight: FontWeight.w700,
                             color: Theme.of(context).colorScheme.outline,
                             letterSpacing: 1.2,
                           ),
                         ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.medicalDisclaimer,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                       'PRIVACY',
                       style: TextStyle(
                         fontFamily: 'PlusJakartaSans',
                         fontSize: 11,
                         fontWeight: FontWeight.w700,
                         color: Theme.of(context).colorScheme.outline,
                         letterSpacing: 1.2,
                       ),
                     ),
                    const SizedBox(height: 8),
                     Text(
                       'Your health data stays on your device. Disconnect Health Connect anytime to erase everything.',
                       style: TextStyle(
                         fontFamily: 'PlusJakartaSans',
                         fontSize: 13,
                         color: Theme.of(context).colorScheme.onSurface,
                         height: 1.5,
                       ),
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: AppButton(
                  label: 'Open privacy policy',
                  onPressed: () => context.push('/privacy'),
                  variant: AppButtonVariant.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
