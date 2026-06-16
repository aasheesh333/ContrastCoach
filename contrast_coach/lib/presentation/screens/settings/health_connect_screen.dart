import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/health/health_connect_client.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
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
        (err) => setState(() {
          _error = err.message;
          _loading = false;
        }),
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
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.brandWarm.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const AppIcon(
                            LucideIcons.heart,
                            size: 20,
                            color: AppColors.brandWarm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Health data stays on your device. We never upload it.',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Read: heart rate, HRV, sleep, steps, workouts. Write: MindfulSession.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: AppColors.darkGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (_snapshot != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.warmBeige,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _SnapshotRow(
                        icon: LucideIcons.activity,
                        color: AppColors.brandWarm,
                        label: _snapshot!.hrvRmssd7DayAvg != null
                            ? 'HRV 7-day avg'
                            : 'HRV',
                        value: _snapshot!.hrvRmssd7DayAvg != null
                            ? '${_snapshot!.hrvRmssd7DayAvg!.toStringAsFixed(1)} ms'
                            : 'not enough data yet',
                      ),
                      const SizedBox(height: 12),
                      _SnapshotRow(
                        icon: LucideIcons.moon,
                        color: AppColors.brandCool,
                        label: 'Sleep',
                        value: _snapshot!.lastNightSleepMinutes != null
                            ? '${(_snapshot!.lastNightSleepMinutes! / 60).toStringAsFixed(1)} h'
                            : 'not recorded',
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: _granted ? 'Reconnect' : 'Connect to Health Connect',
                onPressed: _loading ? null : _connect,
                variant: AppButtonVariant.warm,
                fullWidth: true,
                size: AppButtonSize.large,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: AppColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
