import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
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

  Future<void> _signUp() async {
    if (!_firebaseAvailable) return;
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Email and password are required');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AuthRepositoryImpl(
      auth: FirebaseAuthNullableProxy.auth,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(
        serverClientId: EnvConfig.googleWebClientId,
      ),
    ).signUpWithEmail(_email.text.trim(), _password.text);
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
    final result = await AuthRepositoryImpl(
      auth: FirebaseAuthNullableProxy.auth,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.heroDark),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // v4 brand header
                const Icon(LucideIcons.flame, color: AppColors.heat, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start tracking',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to sync across devices.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
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
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  prefixIcon: LucideIcons.lock,
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
                const SizedBox(height: 24),
                AppButton(
                  label: 'Create account',
                  onPressed: _loading ? null : _signUp,
                  variant: AppButtonVariant.warm,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  isLoading: _loading,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Theme.of(context).colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Continue with Google',
                  onPressed: _loading ? null : _signInGoogle,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  leadingIcon: LucideIcons.mail,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/sign-in'),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: AppColors.heat,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
