import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/delete_user_data.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently removes all your data. This cannot be undone.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: AppColors.darkGray,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkGray)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
      final key = await keyProvider.getOrCreateKey();
      final db = AppDatabase(key);
      final repo = SessionRepositoryImpl(db);

      final result = await deleteAllUserData(
        sessions: repo,
        deleteCloudAccount: () async => await FirebaseAuth.instance.currentUser?.delete(),
      );
      if (result.isOk) {
        if (context.mounted) context.go('/sign-in');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        LucideIcons.trash,
                        color: AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This permanently removes all your local and cloud data. This cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppColors.darkGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Delete account',
                onPressed: () => _deleteAccount(context),
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                size: AppButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
