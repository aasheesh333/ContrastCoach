import 'package:contrast_coach/presentation/widgets/atomic/app_divider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.location});
  final String label;
  final String location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(location),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            const AppIcon(LucideIcons.chevronRight, size: 16),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Settings', showBackButton: true),
      body: SafeArea(
        child: ListView(
          children: const [
            _Row(label: 'Health Connect', location: '/settings/health'),
            AppDivider(),
            _Row(label: 'Privacy', location: '/settings/privacy'),
            AppDivider(),
            _Row(label: 'Export data', location: '/settings/export'),
            AppDivider(),
            _Row(label: 'Delete account', location: '/settings/delete'),
            AppDivider(),
            _Row(label: 'About', location: '/settings/about'),
          ],
        ),
      ),
    );
  }
}
