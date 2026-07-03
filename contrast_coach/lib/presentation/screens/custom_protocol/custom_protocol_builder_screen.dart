import 'dart:convert';

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/custom_protocol_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/validate_custom_protocol.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_slider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:flutter/material.dart';
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
  SubscriptionTier _tier = SubscriptionTier.free;
  bool _checkingAccess = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  Future<void> _loadAccess() async {
    final sharedState = SharedSubscriptionState.instance;
    final repo = SubscriptionRepositoryImpl()..bindSharedState(sharedState);
    await repo.currentTier();
    final tier = sharedState.tier.value;
    if (!mounted) return;
    setState(() {
      _tier = tier;
      _checkingAccess = false;
    });
  }

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

      final db = await DatabaseProvider.instance();
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
    if (_checkingAccess) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.heat),
        ),
      );
    }

    if (!FeatureGating.canUseCustomProtocols(_tier)) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.lock, color: AppColors.heat, size: 32),
                    const SizedBox(height: 16),
                    Text(
                      'Custom protocols are part of Pro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to build your own sauna and plunge sequences, then save them for repeat sessions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Unlock Pro',
                      onPressed: () => context.push('/paywall'),
                      variant: AppButtonVariant.warm,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('NAME'),
              AppTextField(
                label: 'Protocol name',
                controller: _nameController,
                prefixIcon: LucideIcons.tag,
              ),
              const SizedBox(height: 12),
              _sectionTitle('DESCRIPTION'),
              AppTextField(
                label: 'Short description',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _sectionTitle('ROUNDS'),
              Row(
                children: [
                  Text(
                    '$_rounds',
                    style: AppTypography.displaySmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rounds == 1 ? 'round' : 'rounds',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              AppSlider(
                value: _rounds.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _rounds = v.round()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('PHASES (${_phases.length})'),
                  Material(
                    color: AppColors.heat,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    child: InkWell(
                      onTap: _addPhase,
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.plus, size: 16, color: AppColors.white),
                            SizedBox(width: 6),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    AppIcon(LucideIcons.info, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total: ${_buildProtocol().totalDuration.inMinutes}m. Cold 5-20°C. Sauna ≤30 min. ≤60 min total.',
                        style: AppTypography.monoSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Save protocol',
                onPressed: _saving ? null : _save,
                variant: AppButtonVariant.warm,
                fullWidth: true,
                size: AppButtonSize.large,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 1.4,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardSoftFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phase ${index + 1}',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: AppIcon(LucideIcons.x, size: 18, color: Theme.of(context).colorScheme.outline),
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
                    accent: t == PhaseType.sauna
                        ? AppColors.heat
                        : t == PhaseType.cold
                            ? AppColors.cold
                            : AppColors.midGray,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(phase.durationSec / 60).round()}m',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          AppSlider(
            value: phase.durationSec.toDouble().clamp(30, 1800),
            min: 30,
            max: 1800,
            divisions: 59,
            onChanged: (v) => onChanged(phase.copyWith(durationSec: v.round())),
          ),
          if (phase.type != PhaseType.rest) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${phase.tempC.toStringAsFixed(0)}°C',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            AppSlider(
              value: phase.tempC.clamp(0, 90),
              min: 0,
              max: 90,
              divisions: 90,
              activeColor: phase.type == PhaseType.sauna ? AppColors.heat : AppColors.cold,
              onChanged: (v) => onChanged(phase.copyWith(tempC: v)),
            ),
          ],
        ],
      ),
    );
  }
}

