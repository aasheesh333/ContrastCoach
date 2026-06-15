import 'package:contrast_coach/data/local/health/health_connect_client.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});
  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  bool _loading = false;

  Future<void> _connect() async {
    setState(() => _loading = true);
    try {
      final client = HealthConnectClient();
      final result = await client.requestPermissions();
      if (!mounted) return;
      result.fold(
        (err) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied: $err')),
        ),
        (granted) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? 'Health Connect connected' : 'Permission not granted'),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Health Connect', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health data stays on your device. We never upload it.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              AppButton(
                label: 'Connect',
                onPressed: _loading ? null : _connect,
                variant: AppButtonVariant.primary,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
