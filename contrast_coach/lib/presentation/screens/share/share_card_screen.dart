import 'dart:ui';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/render_share_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/share_card_painter.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// v4 SHARE CARD screen (Spec §3.2 row 8).
///
/// Renders the most recent session via [ShareCardPainter] wrapped in a
/// RepaintBoundary (keyed by [_boundaryKey]). The "Share to..." button
/// captures the boundary to PNG via [capturePng] and invokes the system
/// share sheet; on any failure it falls back to a text-only share.
///
/// NOTE: [capturePng] relies on [RenderRepaintBoundary.toImage], which
/// hangs in headless CI; it is therefore only ever invoked from the
/// button (a real-device path) and never from unit tests.
class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({super.key, this.sessionId});

  /// Optional route param. When null the screen loads the most recent
  /// session from [SessionRepositoryImpl.getAll] (limit: 1).
  final String? sessionId;

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Session? _session;
  double? _recoveryScore;
  int _streakDays = 0;
  bool _loading = true;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);

    Session? latest;
    List<Session> sessions = const [];
    if (widget.sessionId != null) {
      final result = await repo.getById(widget.sessionId!);
      if (result is Ok<Session?, AppException>) {
        latest = result.value;
      }
      final allResult = await repo.getAll();
      sessions = allResult is Ok<List<Session>, AppException>
          ? allResult.value
          : const <Session>[];
    } else {
      final allResult = await repo.getAll(limit: 1);
      sessions = allResult is Ok<List<Session>, AppException>
          ? allResult.value
          : const <Session>[];
      latest = sessions.isEmpty ? null : sessions.first;
    }

    if (!mounted) return;
    setState(() {
      _session = latest;
      _recoveryScore = latest?.recoveryScore;
      _streakDays = _countConsecutivePriorDays(sessions, latest);
      _loading = false;
    });
  }

  /// Count consecutive days ending on [latest]'s day (or today) that have
  /// at least one session. Simple inline streak (matches dispatch's
  /// "or simpler: count consecutive prior days"); avoids pulling in the
  /// private `_streakDays` helper in `evaluate_achievements.dart`.
  int _countConsecutivePriorDays(List<Session> sessions, Session? latest) {
    if (sessions.isEmpty) return 0;
    final daysWithSessions = sessions
        .map((s) => DateTime(
              s.startedAt.year,
              s.startedAt.month,
              s.startedAt.day,
            ))
        .toSet();
    var streak = 0;
    DateTime cursor;
    if (latest != null) {
      cursor = DateTime(
          latest.startedAt.year, latest.startedAt.month, latest.startedAt.day);
    } else {
      final now = DateTime.now();
      cursor = DateTime(now.year, now.month, now.day);
    }
    while (daysWithSessions.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final pngBytes = await capturePng(_boundaryKey);
      final file = XFile.fromData(pngBytes,
          mimeType: 'image/png', name: 'contrast_session.png');
      await Share.shareXFiles([file], text: 'My ContrastCoach session');
    } catch (_) {
      // fall back to text-only share
      await Share.share('I finished a ContrastCoach session today!');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(
        title: 'Share',
        showBackButton: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.heat),
            )
          : _session == null
              ? const Center(
                  key: ValueKey('no-session'),
                  child: Text('No recent session to share.'),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShareCardPainter(
                          session: _session!,
                          recoveryScore: _recoveryScore,
                          streakDays: _streakDays,
                          boundaryKey: _boundaryKey,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _sharing ? null : _share,
                          icon: _sharing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share_outlined),
                          label: Text(_sharing ? 'Sharing…' : 'Share to...'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.heat,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
