import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 Account & security — mockup `#account`.
///
/// `.appbar` "Account & security" h2.
/// `.field` Email label + input (read-only show email).
/// `.card.list` of 3 rows: 🔑 Change password (rowlink),
///   🔗 Google · connected (rowlink), 🔒 Biometric lock (.set switch).
/// `.btn.ghost2` "Sign out".
/// `.btn` red-gradient `linear-gradient(120deg,#E53935,#ff6b68)` "Delete account"
///   -> /settings/delete.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final email = FirebaseAuthNullableProxy.tryGet()?.currentUser?.email;
    final emailValue = email ?? 'Not signed in';
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const ContrastAppBar(
          title: 'Account & security', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Email',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ext.textMuted,
                  )),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ext.lineColor, width: 1),
                ),
                child: Text(
                  emailValue,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: email == null ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                  children: [
                    _Rowlink(
                      emoji: '🔑',
                      label: 'Change password',
                      onTap: () => _toast(context, 'Password reset emailed'),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _Rowlink(
                      emoji: '🔗',
                      label: 'Google',
                      sublabel: 'connected',
                      onTap: () => _toast(context, 'Google already connected'),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          const Text('Biometric lock',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                          const Spacer(),
                          AppSwitch(
                            value: _biometric,
                            onChanged: (v) => setState(() => _biometric = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.ghost2,
                fullWidth: true,
                marginTop: 0,
                onPressed: () async {
                  final auth = FirebaseAuthNullableProxy.tryGet();
                  if (auth != null) {
                    await auth.signOut();
                  }
                  if (!mounted) return;
                  _toast(context, 'Signed out');
                  context.go('/sign-in');
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Delete account',
                fullWidth: true,
                variant: AppButtonVariant.delete,
                marginTop: 0,
                onPressed: () => context.push('/settings/delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext c, String msg) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Rowlink extends StatelessWidget {
  const _Rowlink(
      {required this.emoji, required this.label, this.sublabel, this.onTap});
  final String emoji;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  text: label,
                  children: sublabel == null
                      ? const []
                      : [
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: sublabel!,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        ],
                ),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text('›',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
