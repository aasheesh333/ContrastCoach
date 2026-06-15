import 'dart:convert';

import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/custom_protocol_repository.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/usecases/validate_custom_protocol.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_slider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

class CustomProtocolBuilderScreen extends StatefulWidget {
  const CustomProtocolBuilderScreen({super.key});

  @override
  State<CustomProtocolBuilderScreen> createState() => _CustomProtocolBuilderScreenState();
}

class _CustomProtocolBuilderScreenState extends State<CustomProtocolBuilderScreen> {
  final _nameController = TextEditingController(text: 'My protocol');
  final _descriptionController = TextEditingController(text: 'Custom contrast routine');
  int _rounds = 1;
  final List<_PhaseDraft> _phases = [_PhaseDraft(type: PhaseType.sauna, durationSec: 600, tempC: 80)];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Protocol _buildProtocol() {
    return Protocol(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: ProtocolCategory.custom,
      difficulty: ProtocolDifficulty.intermediate,
      rounds: _rounds,
      isCustom: true,
      phases: _phases
          .map((p) => PhaseTemplate(
                type: p.type,
                duration: Duration(seconds: p.durationSec),
                targetTempC: p.type == PhaseType.rest ? null : p.tempC,
              ))
          .toList(),
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final protocol = _buildProtocol();
      final validation = validateCustomProtocol(protocol);
      if (validation.isErr) {
        final err = (validation as Err<Protocol, AppException>).error;
        setState(() {
          _saving = false;
          _error = (err is ValidationException) ? err.errors.join(', ') : err.message;
        });
        return;
      }

      final storage = const FlutterSecureStorage();
      final key = await SqlcipherKeyProvider(storage: storage).getOrCreateKey();
      final db = AppDatabase(key);
      final repo = CustomProtocolRepository(db);

      final phasesJson = jsonEncode(_phases
          .map((p) => {
                'type': p.type.name,
                'duration': p.durationSec,
                'targetTempC': p.type == PhaseType.rest ? null : p.tempC,
              })
          .toList());

      final result = await repo.save(
        id: protocol.id,
        name: protocol.name,
        description: protocol.description,
        rounds: protocol.rounds,
        phasesJson: phasesJson,
      );

      await db.close();

      if (result.isErr) {
        setState(() {
          _saving = false;
          _error = (result as Err<void, AppException>).error.message;
        });
        return;
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Failed to save: $e';
      });
    }
  }

  void _addPhase() {
    setState(() {
      _phases.add(_PhaseDraft(type: PhaseType.cold, durationSec: 120, tempC: 12));
    });
  }

  void _removePhase(int index) {
    setState(() {
      if (_phases.length > 1) _phases.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Custom protocol', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(label: 'Name', controller: _nameController),
              const SizedBox(height: 12),
              AppTextField(label: 'Description', controller: _descriptionController, maxLines: 2),
              const SizedBox(height: 24),
              Text('Rounds: $_rounds', style: tt.titleMedium),
              AppSlider(
                value: _rounds.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _rounds = v.round()),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Phases (${_phases.length})', style: tt.titleMedium),
                  AppButton(
                    label: 'Add',
                    onPressed: _addPhase,
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._phases.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _PhaseEditor(
                        phase: e.value,
                        index: e.key,
                        onChanged: (p) => setState(() => _phases[e.key] = p),
                        onRemove: e.key == 0 ? null : () => _removePhase(e.key),
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const AppIcon(LucideIcons.info, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total: ${_buildProtocol().totalDuration.inMinutes}m. '
                        'Cold 5-20C. Sauna <=30 min. <=60 min total.',
                        style: AppTypography.monoSmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Save protocol',
                onPressed: _saving ? null : _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseDraft {
  _PhaseDraft({required this.type, required this.durationSec, required this.tempC});
  PhaseType type;
  int durationSec;
  double tempC;

  _PhaseDraft copyWith({PhaseType? type, int? durationSec, double? tempC}) =>
      _PhaseDraft(
        type: type ?? this.type,
        durationSec: durationSec ?? this.durationSec,
        tempC: tempC ?? this.tempC,
      );
}

class _PhaseEditor extends StatelessWidget {
  const _PhaseEditor({
    required this.phase,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });
  final _PhaseDraft phase;
  final int index;
  final ValueChanged<_PhaseDraft> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phase ${index + 1}', style: tt.titleSmall),
              if (onRemove != null)
                IconButton(
                  icon: const AppIcon(LucideIcons.x, size: 18),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PhaseType.values
                .where((t) => t != PhaseType.custom)
                .map(
                  (t) => AppChip(
                    label: t.name.toUpperCase(),
                    selected: phase.type == t,
                    onSelected: () => onChanged(phase.copyWith(type: t)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text('Duration: ${(phase.durationSec / 60).round()}m', style: tt.bodyMedium),
          AppSlider(
            value: phase.durationSec.toDouble().clamp(30, 1800),
            min: 30,
            max: 1800,
            divisions: 59,
            onChanged: (v) => onChanged(phase.copyWith(durationSec: v.round())),
          ),
          if (phase.type != PhaseType.rest) ...[
            Text('Temp: ${phase.tempC.toStringAsFixed(0)}C', style: tt.bodyMedium),
            AppSlider(
              value: phase.tempC.clamp(0, 90),
              min: 0,
              max: 90,
              divisions: 90,
              onChanged: (v) => onChanged(phase.copyWith(tempC: v)),
            ),
          ],
        ],
      ),
    );
  }
}
