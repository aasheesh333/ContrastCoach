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
  late final AuthRepository _auth = AuthRepositoryImpl(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance, googleSignIn: GoogleSignIn());

  Future<void> _signInEmail() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) { setState(() => _error = 'Email and password are required'); return; }
    setState(() { _loading = true; _error = null; });
    final result = await _auth.signInWithEmail(_email.text.trim(), _password.text);
    if (!mounted) return;
    result.fold((err) => setState(() { _error = err.message; _loading = false; }), (_) => context.go('/home'));
  }

  Future<void> _signInGoogle() async {
    setState(() { _loading = true; _error = null; });
    final result = await _auth.signInWithGoogle();
    if (!mounted) return;
    result.fold((err) => setState(() { _error = err.message; _loading = false; }), (_) => context.go('/home'));
  }

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    if (_email.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your email first'))); return; }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send reset email: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandWarm, AppColors.brandCoral], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)), child: const Center(child: Icon(LucideIcons.thermometer, color: AppColors.white, size: 36)))),
      const SizedBox(height: AppSpacing.xxl),
      Text('Welcome back', style: cs.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.1)),
      const SizedBox(height: AppSpacing.sm),
      Text('Sign in to keep your streak going.', style: cs.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: AppSpacing.xxxl),
      AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], prefixIcon: LucideIcons.mail),
      const SizedBox(height: 14),
      AppTextField(label: 'Password', controller: _password, obscureText: _obscurePassword, autofillHints: const [AutofillHints.password], prefixIcon: LucideIcons.lock, suffix: IconButton(icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, color: cs.outline, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _sendPasswordResetEmail(context), child: Text('Forgot password?', style: cs.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)))),
      if (_error != null) ...[const SizedBox(height: AppSpacing.md), Text(_error!, style: cs.textTheme.bodySmall?.copyWith(color: cs.error, fontWeight: FontWeight.w500))],
      const SizedBox(height: AppSpacing.xxl),
      AppButton(label: 'Sign in', onPressed: _loading ? null : _signInEmail, variant: AppButtonVariant.warm, fullWidth: true, size: AppButtonSize.large, isLoading: _loading),
      const SizedBox(height: AppSpacing.md),
      Row(children: [Expanded(child: Divider(color: cs.outline.withOpacity(0.3))), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), child: Text('or', style: cs.textTheme.bodySmall?.copyWith(color: cs.outline, fontWeight: FontWeight.w500))), Expanded(child: Divider(color: cs.outline.withOpacity(0.3)))]),
      const SizedBox(height: AppSpacing.md),
      AppButton(label: 'Continue with Google', onPressed: _loading ? null : _signInGoogle, variant: AppButtonVariant.secondary, fullWidth: true, leadingIcon: LucideIcons.mail),
      const SizedBox(height: AppSpacing.xxl),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('New here?', style: cs.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)), TextButton(onPressed: () => context.push('/sign-up'), child: Text('Create account', style: cs.textTheme.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: AppSpacing.sm),
      Center(child: Text(AppStrings.medicalDisclaimer.split('.').first + '.', textAlign: TextAlign.center, style: cs.textTheme.bodySmall?.copyWith(color: cs.outline))),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}
