import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});
  final String sessionId;
  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  Session? _session;
  bool _loading = true;

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

    final result = await repo.getById(widget.sessionId);
    if (result is Ok<Session?, AppException>) {
      final session = result.value;
      if (mounted) setState(() { _session = session; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  domain.RecoveryScore _buildScore(Session session) {
    final value = session.recoveryScore ?? 0;
    final band = value >= 75
        ? ScoreBand.strong
        : value >= 50
            ? ScoreBand.moderate
            : ScoreBand.low;
    final adherence = session.protocolRounds > 0
        ? (session.roundsCompleted / session.protocolRounds * 100).round()
        : 100;
    return domain.RecoveryScore(
      value: value,
      band: band,
      insight: 'Adherence: Completed $adherence% of planned rounds.',
      factors: const [],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Session complete', showBackButton: false),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _session == null
                ? const Center(child: Text('Session not found'))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RecoveryScoreCard(score: _buildScore(_session!)),
                        const SizedBox(height: 24),
                        Text('Duration: ${_formatDuration(_session!.totalActualDuration)}',
                            style: tt.bodyLarge),
                        const SizedBox(height: 4),
                        Text(
                            'Rounds: ${_session!.roundsCompleted} / ${_session!.protocolRounds}',
                            style: tt.bodyLarge),
                        const SizedBox(height: 16),
                        ...(_session!.phases.map(
                          (p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '${p.type.name}  ${_formatDuration(p.actualDuration ?? p.plannedDuration)}  ${p.skipped ? "(skipped)" : ""}',
                              style: tt.bodyMedium,
                            ),
                          ),
                        )),
                        const Spacer(),
                        AppButton(
                          label: 'Save',
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Discard',
                          onPressed: () => context.go('/home'),
                          variant: AppButtonVariant.text,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
