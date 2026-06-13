import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _analytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Privacy', showBackButton: true),
      body: SafeArea(
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Helps us improve the app.'),
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v),
            ),
          ],
        ),
      ),
    );
  }
}
