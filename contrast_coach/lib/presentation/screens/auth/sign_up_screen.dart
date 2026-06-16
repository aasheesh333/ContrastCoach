import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/repositories/auth_repository.dart';
import 'package:contrast_coach/domain/repositories/auth_repository.dart';
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
  late final AuthRepository _auth = AuthRepositoryImpl(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
  );

  Future<void> _signUp() async {
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
    final result = await _auth.signUpWithEmail(_email.text.trim(), _password.text);
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
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _auth.signInWithGoogle();
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
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandWarm, AppColors.brandCoral],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(LucideIcons.thermometer, color: AppColors.white, size: 36),
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
              const Text(
                'Create an account to sync across devices.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  color: AppColors.darkGray,
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
                  const Expanded(child: Divider(color: AppColors.lightGray)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: AppColors.midGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.lightGray)),
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
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.darkGray,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: AppColors.brandWarm,
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
    );
  }
}
