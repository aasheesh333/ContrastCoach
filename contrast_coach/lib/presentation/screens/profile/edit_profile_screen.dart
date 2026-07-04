import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/data/repositories/user_profile_service.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 EDIT PROFILE screen — full identity editor.
///
/// Layout per mockup #editProfile:
/// - AppBar "Edit profile" 19/w800/ls-.4 with chip back button
/// - 88×88 heat→cold gradient avatar with emoji
/// - 5-emoji picker row
/// - Name field (radius 12)
/// - Bio textarea (radius 12)
/// - Primary goal chips (Recovery/Energy/Sleep/Focus)
/// - Temperature units segmented control (°C / °F)
/// - Weekly session goal slider
/// - Save changes heat-gradient button
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String _avatarEmoji = '🧑';
  String _primaryGoal = 'Recovery';
  String _tempUnit = '°C';
  double _weeklyGoal = 5;

  static const _avatarEmojis = ['🧑', '🧔', '👩', '🧊', '🔥'];
  static const _goals = ['Recovery', 'Energy', 'Sleep', 'Focus'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuthNullableProxy.tryGet()?.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final user = FirebaseAuthNullableProxy.tryGet()?.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in required')),
        );
      }
      return;
    }
    try {
      await user.updateDisplayName(_nameController.text.trim());
      await user.reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/settings');
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      appBar: const ContrastAppBar(
        title: 'Edit profile',
        showBackButton: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          children: [
            // Avatar (88×88 gradient circle + emoji)
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-0.27, -1),
                    end: Alignment(0.27, 1),
                    colors: [AppColors.heat, AppColors.cold],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _avatarEmoji,
                  style: const TextStyle(fontSize: 34, height: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Emoji picker row (5 emojis)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final emoji in _avatarEmojis) ...[
                  GestureDetector(
                    onTap: () => setState(() => _avatarEmoji = emoji),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: _avatarEmoji == emoji
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.heat,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22, height: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (emoji != _avatarEmojis.last) const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl + 8),
            // Name field
            _FieldLabel(text: 'Name'),
            const SizedBox(height: 6),
            _V4TextField(
              controller: _nameController,
              hint: 'Your name',
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bio textarea
            _FieldLabel(text: 'Bio'),
            const SizedBox(height: 6),
            _V4TextField(
              controller: _bioController,
              hint: 'Contrast therapy since 2024',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Primary goal chips
            _FieldLabel(text: 'Primary goal'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final goal in _goals)
                  GestureDetector(
                    onTap: () => setState(() => _primaryGoal = goal),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryGoal == goal
                            ? AppColors.heat
                            : cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _primaryGoal == goal
                              ? AppColors.heat
                              : ext.lineColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        goal,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primaryGoal == goal
                              ? AppColors.white
                              : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Temperature units segmented control
            _FieldLabel(text: 'Temperature units'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ext.lineColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  for (final unit in ['°C', '°F'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tempUnit = unit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _tempUnit == unit
                                ? cs.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _tempUnit == unit
                                ? const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                      spreadRadius: -3,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFont,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Weekly session goal slider
            _FieldLabel(text: 'Weekly session goal'),
            const SizedBox(height: 4),
            Slider(
              value: _weeklyGoal,
              min: 1,
              max: 14,
              divisions: 13,
              activeColor: AppColors.heat,
              onChanged: (v) => setState(() => _weeklyGoal = v),
            ),
            Text(
              '${_weeklyGoal.round()} sessions / week',
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Save button (heat gradient)
            AppButton(
              label: 'Save changes',
              onPressed: _onSave,
              variant: AppButtonVariant.primary,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTypography.bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: cs.onSurface,
      ),
    );
  }
}

class _V4TextField extends StatelessWidget {
  const _V4TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.all(13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.lineColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.lineColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ext.lineColor, width: 1),
        ),
      ),
      style: TextStyle(
        fontFamily: AppTypography.bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }
}
