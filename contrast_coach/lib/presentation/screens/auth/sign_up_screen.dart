import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_strings.dart';
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
  bool _obscurePassword = true;
  String? _error;
  late final AuthRepository _auth = AuthRepositoryImpl(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance, googleSignIn: GoogleSignIn());

  Future<void> _signUpEmail() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) { setState(() => _error = 'Email and password are required'); return; }
    if (_password.text.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }
    setState(() { _loading = true; _error = null; });
    final result = await _auth.signUpWithEmail(_email.text.trim(), _password.text);
    if (!mounted) return;
    result.fold((err) => setState(() { _error = err.message; _loading = false; }), (_) => context.go('/home'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandWarm, AppColors.brandCoral], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)), child: const Center(child: Icon(LucideIcons.thermometer, color: AppColors.white, size: 36)))),
      const SizedBox(height: AppSpacing.xxl),
      Text('Create account', style: cs.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
      const SizedBox(height: AppSpacing.sm),
      Text('Start your contrast therapy journey.', style: cs.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: AppSpacing.xxxl),
      AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], prefixIcon: LucideIcons.mail),
      const SizedBox(height: 14),
      AppTextField(label: 'Password', controller: _password, obscureText: _obscurePassword, autofillHints: const [AutofillHints.newPassword], prefixIcon: LucideIcons.lock, suffix: IconButton(icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, color: cs.outline, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
      if (_error != null) ...[const SizedBox(height: AppSpacing.md), Text(_error!, style: cs.textTheme.bodySmall?.copyWith(color: cs.error))],
      const SizedBox(height: AppSpacing.xxl),
      AppButton(label: 'Create account', onPressed: _loading ? null : _signUpEmail, variant: AppButtonVariant.warm, fullWidth: true, size: AppButtonSize.large, isLoading: _loading),
      const SizedBox(height: AppSpacing.xxl),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Already have an account?', style: cs.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)), TextButton(onPressed: () => context.go('/sign-in'), child: Text('Sign in', style: cs.textTheme.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: AppSpacing.sm),
      Center(child: Text(AppStrings.medicalDisclaimer.split('.').first + '.', textAlign: TextAlign.center, style: cs.textTheme.bodySmall?.copyWith(color: cs.outline))),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}
