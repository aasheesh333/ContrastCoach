import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Edit profile screen — reads/writes Firebase Auth profile.
///
/// Renders gracefully when there is no signed-in user (or Firebase is not
/// initialized, e.g. in tests): the display-name field is cleared, the email
/// is shown as a dash, and the Save button is disabled with a "Sign in
/// required" hint. See spec §3.2 row 10.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  String _email = '';
  bool _userIsNull = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuthNullableProxy.tryGet()?.currentUser;
    if (user == null) {
      _userIsNull = true;
      _displayNameController = TextEditingController(text: '');
      _email = '';
    } else {
      _displayNameController =
          TextEditingController(text: user.displayName ?? '');
      _email = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_userIsNull || _saving) return;
    setState(() => _saving = true);
    try {
      final user = FirebaseAuthNullableProxy.tryGet()?.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in required')),
          );
        }
        return;
      }
      await user.updateDisplayName(_displayNameController.text.trim());
      await user.reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _displayNameController,
                enabled: !_userIsNull,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _email.isEmpty ? '—' : _email,
                style: TextStyle(
                  fontSize: 15,
                  color: _userIsNull ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_userIsNull)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'Sign in required',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: (_userIsNull || _saving) ? null : _onSave,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
