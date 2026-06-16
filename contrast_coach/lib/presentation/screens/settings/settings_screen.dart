import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_divider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.location,
    this.icon,
    this.iconColor,
    this.trailing,
  });
  final String label;
  final String? location;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: location == null ? null : () => context.push(location!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
                  fontSize: 16,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const AppIcon(LucideIcons.chevronRight, size: 18, color: AppColors.midGray),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.midGray,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voice = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24, color: AppColors.charcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.brandWarm, AppColors.brandCoral],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'AJ',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Johnson',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Free plan',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.brandWarm,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      child: InkWell(
                        onTap: () => context.push('/paywall'),
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            'Pro',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Appearance
              const _SectionTitle('APPEARANCE'),
              const _SettingsRow(
                label: 'Theme',
                icon: LucideIcons.sun,
                iconColor: AppColors.brandWarm,
                trailing: Icon(LucideIcons.chevronRight, size: 18, color: AppColors.midGray),
              ),
              const AppDivider(),
              const _SettingsRow(
                label: 'Accent color',
                icon: LucideIcons.droplet,
                iconColor: AppColors.brandCool,
                trailing: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Orange', style: TextStyle(fontSize: 14, color: AppColors.midGray)),
                      SizedBox(width: 8),
                      Icon(LucideIcons.chevronRight, size: 18, color: AppColors.midGray),
                    ],
                  ),
                ),
              ),

              // Health
              const _SectionTitle('HEALTH'),
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
                  onChanged: (v) => setState(() => _voice = v),
                ),
              ),
              const AppDivider(),
              _SettingsRow(
                label: 'Notifications',
                icon: LucideIcons.bell,
                iconColor: AppColors.brandCoral,
                trailing: AppSwitch(
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ),

              // Privacy
              const _SectionTitle('PRIVACY'),
              const _SettingsRow(
                label: 'Privacy',
                icon: LucideIcons.shield,
                iconColor: AppColors.brandWarm,
                location: '/settings/privacy',
              ),
              const AppDivider(),
              const _SettingsRow(
                label: 'Export data',
                icon: LucideIcons.download,
                iconColor: AppColors.brandCool,
                location: '/settings/export',
              ),
              const AppDivider(),
              const _SettingsRow(
                label: 'Delete account',
                icon: LucideIcons.trash,
                iconColor: AppColors.error,
                location: '/settings/delete',
              ),

              // Help
              const _SectionTitle('HELP'),
              const _SettingsRow(
                label: 'About',
                icon: LucideIcons.info,
                iconColor: AppColors.midGray,
                location: '/settings/about',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
