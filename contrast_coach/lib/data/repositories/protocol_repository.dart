import 'dart:convert';

import 'package:contrast_coach/core/constants/app_assets.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProtocolRepositoryImpl implements ProtocolRepository {
  @override
  Future<Result<List<Protocol>, AppException>> getAll() async {
    try {
      final json = await rootBundle.loadString(AppAssets.protocolsJson);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      final list = (parsed['protocols'] as List)
          .map((p) => _parseProtocol(p as Map<String, dynamic>))
          .toList();
      return Ok(list);
    } catch (e) {
      return Err(DatabaseException('Failed to load protocols', cause: e));
    }
  }

  @override
  Future<Result<Protocol?, AppException>> getById(String id) async {
    final allResult = await getAll();
    return allResult.fold(
      (err) => Err(err),
      (list) {
        for (final p in list) {
          if (p.id == id) return Ok(p);
        }
        return const Ok(null);
      },
    );
  }

  Protocol _parseProtocol(Map<String, dynamic> json) {
    final phasesRaw = (json['phases'] as List?) ?? const [];
    final phases = phasesRaw
        .map((p) => _parsePhaseTemplate(p as Map<String, dynamic>))
        .toList();
    return Protocol(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      category: ProtocolCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'custom'),
        orElse: () => ProtocolCategory.custom,
      ),
      difficulty: ProtocolDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'intermediate'),
        orElse: () => ProtocolDifficulty.intermediate,
      ),
      rounds: (json['rounds'] as int?) ?? 1,
      phases: phases,
      isPro: (json['isPro'] as bool?) ?? false,
      isCustom: (json['isCustom'] as bool?) ?? false,
    );
  }

  PhaseTemplate _parsePhaseTemplate(Map<String, dynamic> json) {
    return PhaseTemplate(
      type: PhaseType.fromString(json['type'] as String),
      duration: Duration(seconds: (json['duration'] as num).toInt()),
      targetTempC: (json['targetTempC'] as num?)?.toDouble(),
    );
  }
}
