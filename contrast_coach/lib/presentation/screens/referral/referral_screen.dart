import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// v4 Referral screen (spec §3.2 row 7).
///
/// Derives a deterministic 6-char referral code from the signed-in user's
/// UID — no backend table required. Renders the v4 hero header and a Card
/// holding the code with Copy / Share actions.
class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  String _referralCode(String? uid) {
    if (uid == null || uid.isEmpty) return 'GUEST0';
    final hash = uid.hashCode.abs().toRadixString(36).toUpperCase();
    return 'CC-${hash.length >= 4 ? hash.substring(0, 4) : hash.padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuthNullableProxy.tryGet()?.currentUser?.uid;
    final code = _referralCode(uid);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _HeroHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppColors.heat, width: 1.5),
                    ),
                    elevation: 0,
                    color: cs.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your referral code',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heat,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            code,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => Clipboard.setData(
                                    ClipboardData(text: code),
                                  ),
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  label: const Text('Copy'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Share.share(
                                    'Join me on ContrastCoach! Use my code: $code',
                                  ),
                                  icon: const Icon(Icons.share_outlined, size: 18),
                                  label: const Text('Share'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// v4 hero strip — gradient band holding the screen title and subtitle.
class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.splashBg),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Invite friends, earn Pro',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Share your code. When a friend joins, you both unlock Pro rewards.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
