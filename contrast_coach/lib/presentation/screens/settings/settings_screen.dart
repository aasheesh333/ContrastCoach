import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:contrast_coach/data/repositories/auth_repository.dart';
import 'package:contrast_coach/data/repositories/user_profile_service.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/auth_repository.dart' as domain;
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_divider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/atomic/identity.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile _profile = const UserProfile(
    uid: '',
    email: '',
    displayName: '',
    initials: 'C',
    photoURL: null,
    subscriptionStatus: 'free',
    createdAt: null,
  );
  SessionStats _stats = computeSessionStats(const []);
  bool _voice = true;
  bool _notifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileService = UserProfileService(
      auth: FirebaseAuthNullableProxy.auth,
      firestore: FirebaseFirestore.instance,
    );
    final profileResult = await profileService.current();
    final profile = profileResult is Ok<UserProfile, AppException>
        ? profileResult.value
        : _profile;

    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);
    final sessionsResult = await repo.getAll();
    final sessions = sessionsResult is Ok<List<Session>, AppException>
        ? sessionsResult.value
        : <Session>[];

    if (mounted) {
      setState(() {
        _profile = profile;
        _stats = computeSessionStats(sessions);
        _voice = AppPreferences.voiceEnabled;
        _notifications = AppPreferences.notificationsEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _setVoice(bool value) async {
    await AppPreferences.setVoiceEnabled(value);
    if (!mounted) return;
    setState(() => _voice = value);
  }

  Future<void> _setNotifications(bool value) async {
    await AppPreferences.setNotificationsEnabled(value);
    if (!mounted) return;
    setState(() => _notifications = value);
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?'),
        content: const Text('Your local data will remain on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;
    final auth = AuthRepositoryImpl(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(),
    );
    await auth.signOut();
    if (mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'Profile', showBackButton: true),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brandWarm),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.huge,
                ),
                children: [
                  _ProfileCard(
                    profile: _profile,
                    stats: _stats,
                    onUpgrade: () => context.push('/paywall'),
                  ),
                  const SectionHeader(label: 'Appearance'),
                  _SettingsRow(
                    label: 'Theme',
                    icon: LucideIcons.sun,
                    iconColor: AppColors.brandWarm,
                    trailing: const _TrailingValue(
                      label: 'System',
                      icon: LucideIcons.chevronRight,
                    ),
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Accent color',
                    icon: LucideIcons.droplet,
                    iconColor: AppColors.brandCool,
                    trailing: const _TrailingValue(
                      label: 'Orange',
                      icon: LucideIcons.chevronRight,
                    ),
                  ),
                  const SectionHeader(label: 'Health'),
                  _SettingsRow(
                    label: 'Health Connect',
                    icon: LucideIcons.heart,
                    iconColor: AppColors.brandWarm,
                    location: '/settings/health',
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Voice control',
                    icon: LucideIcons.mic,
                    iconColor: AppColors.brandCool,
                    trailing: AppSwitch(
                      value: _voice,
                      onChanged: (value) => _setVoice(value),
                    ),
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Notifications',
                    icon: LucideIcons.bell,
                    iconColor: AppColors.brandCoral,
                    trailing: AppSwitch(
                      value: _notifications,
                      onChanged: (value) => _setNotifications(value),
                    ),
                  ),
                  const SectionHeader(label: 'Privacy'),
                  _SettingsRow(
                    label: 'Privacy',
                    icon: LucideIcons.shield,
                    iconColor: AppColors.brandWarm,
                    location: '/settings/privacy',
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Export data',
                    icon: LucideIcons.download,
                    iconColor: AppColors.brandCool,
                    location: '/settings/export',
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Delete account',
                    icon: LucideIcons.trash2,
                    iconColor: AppColors.error,
                    location: '/settings/delete',
                  ),
                  const SectionHeader(label: 'Subscription'),
                  _SettingsRow(
                    label: 'Manage subscription',
                    icon: LucideIcons.creditCard,
                    iconColor: AppColors.brandCoral,
                    location: '/paywall',
                  ),
                  const SectionHeader(label: 'Help'),
                  _SettingsRow(
                    label: 'About',
                    icon: LucideIcons.info,
                    iconColor: AppColors.midGray,
                    location: '/settings/about',
                  ),
                  const AppDivider(),
                  _SettingsRow(
                    label: 'Sign out',
                    icon: LucideIcons.logOut,
                    iconColor: AppColors.error,
                    onTap: _signOut,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.stats,
    required this.onUpgrade,
  });
  final UserProfile profile;
  final SessionStats stats;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final hasName = profile.displayName.isNotEmpty;
    final isPro = profile.subscriptionStatus.toLowerCase() == 'pro';
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      radius: 24,
      elevation: AppCardElevation.soft,
      child: Row(
        children: [
          UserAvatar(
            initials: profile.initials,
            photoUrl: profile.photoURL,
            size: 56,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? profile.displayName : 'Guest user',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasName
                      ? profile.email
                      : 'Sign in to sync across devices.',
                  style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                    fontSize: 12,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PlanBadge(
                      subscriptionStatus: profile.subscriptionStatus,
                      onTap: isPro ? null : onUpgrade,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stats.isEmpty
                          ? 'No sessions yet'
                          : '${stats.totalSessions} sessions tracked',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: AppColors.midGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailingValue extends StatelessWidget {
  const _TrailingValue({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: AppColors.midGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 4),
          Icon(icon, size: 18, color: AppColors.midGray),
        ],
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.icon,
    this.iconColor,
    this.location,
    this.trailing,
    this.onTap,
  });
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final String? location;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = location != null || onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tappable
            ? (onTap ?? () => context.push(location!))
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 2,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.brandWarm).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.brandWarm, size: 16),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: AppColors.midGray,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
