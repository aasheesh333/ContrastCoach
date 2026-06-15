import 'dart:io';

import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/export_user_data.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  Future<void> _export(BuildContext context) async {
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Export data', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Export all your sessions to a JSON file.'),
              const Spacer(),
              AppButton(label: 'Export', onPressed: () => _export(context)),
            ],
          ),
        ),
      ),
    );
  }
}
