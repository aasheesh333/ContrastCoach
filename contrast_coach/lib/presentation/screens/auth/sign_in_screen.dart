import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Sign in', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _password, obscureText: true, autofillHints: const [AutofillHints.password]),
              const Spacer(),
              AppButton(label: 'Sign in', onPressed: () => context.go('/home')),
              const SizedBox(height: 8),
              AppButton(label: 'Create account', onPressed: () => context.push('/sign-up'), variant: AppButtonVariant.text),
            ],
          ),
        ),
      ),
    );
  }
}
