import 'dart:convert';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// v4 Challenges screen — mockup `#community`.
///
/// `.name` "Challenges" 28 w800.
/// `.hero` dark `linear-gradient(140deg,#12121a,#25252f)` radius 26 padding 20
///   with cold-blue box-shadow `0 20px 40px -18px rgba(45,124,241,.5)`,
///   radial heat blob top-right + radial cold blob bottom-left,
///   `.lbl` "This week" + `.big` "❄️ Cold Streak Challenge" 19 w800 + subtext
///   "1,240 people joined · 3 days left".
/// Leaderboard `.card.leader` single shared card with 4 flat rows:
///   "1 🥇 Priya S. <b>21</b>", "2 🥈 Marcus <b>19</b>",
///   "7 🔥 You <b>14</b>" (heat-tinted via `.leader .me`), "8 Dana <b>13</b>".
/// `.btn.cold` "Invite friends →" (cold→cold2 gradient, cold shadow).
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Map<String, dynamic>> _leaderboard = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final raw = await rootBundle.loadString('assets/challenges.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      final list = (decoded['leaderboard'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      setState(() {
        _leaderboard = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Unable to load challenges.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.huge,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: Text(
                          'Challenges',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.7,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _Hero(),
                      const SizedBox(height: 14),
                      _Leaderboard(entries: _leaderboard),
                      AppButton(
                        label: 'Invite friends →',
                        variant: AppButtonVariant.cool,
                        fullWidth: true,
                        marginTop: 16,
                        onPressed: () => context.push('/referral'),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.heroDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x802D7CF1),
            blurRadius: 40,
            offset: Offset(0, 20),
            spreadRadius: -18,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.heat.withOpacity(0.55), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Positioned(
            left: -70,
            bottom: -90,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.cold.withOpacity(0.5), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'THIS WEEK',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '❄️ Cold Streak Challenge',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1,240 people joined · 3 days left',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xD9FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.entries});
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final children = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final rank = (e['rank'] as num?)?.toInt() ?? 0;
      final name = (e['displayName'] as String?) ?? '';
      final points = (e['points'] as num?)?.toInt() ?? 0;
      final isYou = (e['isYou'] as bool?) ?? false;
      final medal = switch (rank) {
        1 => '🥇',
        2 => '🥈',
        _ when isYou => '🔥',
        _ => '',
      };
      final nameColor = isYou ? AppColors.heat : cs.onSurface;
      final rkColor = cs.onSurfaceVariant;
      final row = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: rkColor,
                ),
              ),
            ),
            if (medal.isNotEmpty) ...[
              Text(medal, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: nameColor,
                ),
              ),
            ),
            Text(
              '$points',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: nameColor,
              ),
            ),
          ],
        ),
      );
      children.add(row);
      if (i < entries.length - 1) {
        children.add(Container(height: 1, color: ext.lineColor));
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ext.lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14142D),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
