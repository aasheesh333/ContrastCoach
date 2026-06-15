import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/health/health_connect_client.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});
  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  bool _loading = false;
  bool _granted = false;
  HealthSnapshot? _snapshot;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final client = HealthConnectClient();
    final result = await client.isAvailable();
    if (!mounted) return;
    result.fold(
      (err) => setState(() => _error = err.message),
      (avail) => setState(() => _granted = avail),
    );
  }

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = HealthConnectClient();
      final result = await client.requestPermissions();
      if (!mounted) return;
      result.fold(
        (err) {
          setState(() {
            _error = err.message;
            _loading = false;
          });
        },
        (granted) async {
          if (granted) {
            final snapResult = await client.readSnapshot();
            if (!mounted) return;
            snapResult.fold(
              (err) => setState(() {
                _error = err.message;
                _loading = false;
              }),
              (snapshot) => setState(() {
                _snapshot = snapshot;
                _granted = true;
                _loading = false;
              }),
            );
          } else {
            setState(() {
              _granted = false;
              _loading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection failed: $e';
          _loading = false;
        });
      }
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
              const SizedBox(height: 8),
              Text(
                'Read: heart rate, HRV, sleep, steps, workouts. Write: MindfulSession.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (_snapshot != null) ...[
                AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppIcon(LucideIcons.heart, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _snapshot!.hrvRmssd7DayAvg != null
                                ? 'HRV 7-day avg: ${_snapshot!.hrvRmssd7DayAvg!.toStringAsFixed(1)} ms'
                                : 'HRV: not enough data yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const AppIcon(LucideIcons.moon, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _snapshot!.lastNightSleepMinutes != null
                                ? 'Sleep: ${(_snapshot!.lastNightSleepMinutes! / 60).toStringAsFixed(1)} h'
                                : 'Sleep: not recorded',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              AppButton(
                label: _granted ? 'Reconnect' : 'Connect',
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
