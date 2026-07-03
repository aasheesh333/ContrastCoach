import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_refcode.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// v4 Referral screen — mockup `#referral`.
///
/// Standard `.appbar` "Invite friends" 19 w800.
/// A single centered `.card`:
///   🎁 emoji 34px,
///   "Give a month, get a month" w800,
///   "Both you and your friend get 1 month of Pro free." 13 ink2,
///   `.refcode` (2px dashed heat border, JetBrains Mono 26 w500 ls2, heat color),
///   `.btn` "Share invite link" heat→coral gradient.
class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  String _referralCode(String? uid) {
    if (uid == null || uid.isEmpty) return 'AASHEESH50';
    final hash = uid.hashCode.abs().toRadixString(36).toUpperCase();
    return hash.length >= 8 ? hash.substring(0, 8) : hash.padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final uid = FirebaseAuthNullableProxy.tryGet()?.currentUser?.uid;
    final code = _referralCode(uid);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(title: 'Invite friends', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎁', style: TextStyle(fontSize: 34)),
                const SizedBox(height: 8),
                const Text(
                  'Give a month, get a month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Both you and your friend get 1 month of Pro free.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                AppRefCode(code: code),
                AppButton(
                  label: 'Share invite link',
                  fullWidth: true,
                  marginTop: 4,
                  onPressed: () => Share.share(
                    'Join me on ContrastCoach! Use my code: $code',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
