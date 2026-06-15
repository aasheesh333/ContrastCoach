import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/composite/hero_start_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/quick_stats_row.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streakDays = 0;
  int _avgDurationMin = 0;
  double? _lastScore;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    final db = AppDatabase(key);
    final repo = SessionRepositoryImpl(db);

    _streakDays = await repo.getStreakDays();

    final sessionsResult = await repo.getAll();
    if (sessionsResult is Ok<List<Session>, AppException>) {
      final sessions = sessionsResult.value;
      if (sessions.isNotEmpty) {
        final totalSec = sessions.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
        _avgDurationMin = (totalSec / sessions.length / 60).round();
        _lastScore = sessions.first.recoveryScore;
      }
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Home'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HeroStartCard(),
              const SizedBox(height: 16),
              QuickStatsRow(
                streakDays: _streakDays,
                avgDurationMin: _avgDurationMin,
                lastScore: _lastScore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
