import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/data/repositories/auth_repository.dart';
import 'package:contrast_coach/domain/repositories/auth_repository.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  bool get _firebaseAvailable => FirebaseAuthNullableProxy.tryGet() != null;

  @override
  void initState() {
    super.initState();
    if (!_firebaseAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
    }
  }

  Future<void> _signInEmail() async {
    if (!_firebaseAvailable) return;
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email and password are required');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = FirebaseAuthNullableProxy.auth;
    final result = await AuthRepositoryImpl(
      auth: auth,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(
        serverClientId: EnvConfig.googleWebClientId,
      ),
    ).signInWithEmail(_email.text.trim(), _password.text);
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _error = err.message;
        _loading = false;
      }),
      (_) => context.go('/home'),
    );
  }

  Future<void> _signInGoogle() async {
    if (!_firebaseAvailable) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = FirebaseAuthNullableProxy.auth;
    final result = await AuthRepositoryImpl(
      auth: auth,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(
        serverClientId: EnvConfig.googleWebClientId,
      ),
    ).signInWithGoogle();
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _error = err.message;
        _loading = false;
      }),
      (_) => context.go('/home'),
    );
  }

  void _notifyAppleUnsupported() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple Sign-In is coming soon. Use Google for now.'),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inkColor = cs.onSurface;
    final ink2Color = cs.onSurfaceVariant;
    final ink3Color = cs.outline;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: const Text('🧊', style: TextStyle(fontSize: 52, height: 1)),
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: inkColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Recover smarter with every session',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ink2Color,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 26),
              _OAuthRow(
                emoji: '🟢',
                label: 'Continue with Google',
                onTap: _loading ? null : _signInGoogle,
                cardColor: cs.surface,
                lineColor: cs.outline,
                textColor: inkColor,
              ),
              const SizedBox(height: 10),
              _OAuthRow(
                emoji: '🍎',
                label: 'Continue with Apple',
                onTap: _loading ? null : _notifyAppleUnsupported,
                cardColor: cs.surface,
                lineColor: cs.outline,
                textColor: inkColor,
              ),
              const SizedBox(height: 12),
              _OrDivider(ink3Color: ink3Color),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                prefixIcon: LucideIcons.mail,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                controller: _password,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                prefixIcon: LucideIcons.lock,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: cs.outline,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              AppButton(
                label: 'Sign in',
                onPressed: _loading ? null : _signInEmail,
                variant: AppButtonVariant.primary,
                fullWidth: true,
                size: AppButtonSize.large,
                isLoading: _loading,
                marginTop: 4,
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New here? ',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ink3Color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/sign-up'),
                      child: Text(
                        'Create account',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.heat,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.heat,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OAuthRow extends StatelessWidget {
  const _OAuthRow({
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.cardColor,
    required this.lineColor,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color lineColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: lineColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22, height: 1)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.ink3Color});
  final Color ink3Color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: ink3Color),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ink3Color,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: ink3Color),
        ),
      ],
    );
  }
}
