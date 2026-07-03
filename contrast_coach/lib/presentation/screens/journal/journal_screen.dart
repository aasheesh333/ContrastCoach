import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/journal_repository.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late Future<List<JournalEntry>> _load;

  @override
  void initState() {
    super.initState();
    _load = _loadEntries();
  }

  Future<List<JournalEntry>> _loadEntries() async {
    final db = await DatabaseProvider.instance();
    final repo = JournalRepositoryImpl(db);
    final result = await repo.getAll();
    return result is Ok<List<JournalEntry>, AppException>
        ? result.value
        : <JournalEntry>[];
  }

  Future<void> _refresh() async {
    final entries = await _loadEntries();
    if (mounted) {
      setState(() {
        _load = Future.value(entries);
      });
    }
  }

  Future<void> _openAddEntrySheet() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _AddEntrySheet(),
    );
    if (saved == true) await _refresh();
  }

  Future<void> _confirmDelete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This journal entry will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = await DatabaseProvider.instance();
    final repo = JournalRepositoryImpl(db);
    final result = await repo.delete(entry.id);
    if (result is Ok<void, AppException>) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'Journal'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntrySheet,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<JournalEntry>>(
          future: _load,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return _emptyState();
            final items = snapshot.data ?? const <JournalEntry>[];
            if (items.isEmpty) return _emptyState();
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sectionGap + 72,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => _JournalRow(
                  entry: items[i],
                  onLongPress: () => _confirmDelete(items[i]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📝', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No journal entries yet — tap Add to record your first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({required this.entry, required this.onLongPress});
  final JournalEntry entry;
  final VoidCallback onLongPress;

  static const _moodEmoji = {
    'Great': '🟢',
    'Good': '🙂',
    'OK': '😐',
    'Bad': '😕',
    'Terrible': '😣',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _moodEmoji[entry.mood ?? ''] ?? '•';
    final date = '${entry.createdAt.month.toString().padLeft(2, '0')}/'
        '${entry.createdAt.day.toString().padLeft(2, '0')}';
    final note = entry.note ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        if (entry.mood != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            entry.mood!,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        note,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet();

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  static const _moods = ['Great', 'Good', 'OK', 'Bad', 'Terrible'];
  String? _mood;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mood = _mood;
    final note = _noteController.text.trim();
    if (mood == null && note.isEmpty) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    final db = await DatabaseProvider.instance();
    final repo = JournalRepositoryImpl(db);
    final result = await repo.insert(
      mood: mood,
      note: note.isEmpty ? null : note,
    );
    if (!mounted) return;
    Navigator.of(context).pop(result is Ok<JournalEntry, AppException>);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.pageBottom +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New journal entry',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _mood,
            decoration: const InputDecoration(
              labelText: 'Mood',
              border: OutlineInputBorder(),
            ),
            items: _moods
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => _mood = v),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Note',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _save,
            child: const Text('Save entry'),
          ),
        ],
      ),
    );
  }
}
