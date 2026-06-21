import 'dart:io';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/export_user_data.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _exporting = false;
  String? _filePath;

  Future<void> _export(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
      final key = await keyProvider.getOrCreateKey();
      final db = AppDatabase(key);
      final repo = SessionRepositoryImpl(db);

      final sessionsResult = await repo.getAll();
      if (sessionsResult is Ok<List<Session>, AppException>) {
        final sessions = sessionsResult.value;
        final json = exportUserDataAsJson(sessions: sessions, exportedAt: DateTime.now());
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/contrast_coach_export.json');
        await file.writeAsString(json);
        if (mounted) {
          setState(() {
            _filePath = file.path;
            _exporting = false;
          });
          // Show share sheet
          await Share.shareXFiles([XFile(file.path)], text: 'ContrastCoach data export');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _exporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
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
                        color: AppColors.brandWarm.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AppIcon(
                        LucideIcons.download,
                        size: 28,
                        color: AppColors.brandWarm,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export your data',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Download all your sessions as a JSON file.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppColors.darkGray,
                      ),
                    ),
                    if (_filePath != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const AppIcon(LucideIcons.check, size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Saved to: $_filePath',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  color: AppColors.charcoal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: _filePath == null ? 'Export' : 'Export again',
                onPressed: _exporting ? null : () => _export(context),
                variant: AppButtonVariant.warm,
                fullWidth: true,
                size: AppButtonSize.large,
                isLoading: _exporting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}