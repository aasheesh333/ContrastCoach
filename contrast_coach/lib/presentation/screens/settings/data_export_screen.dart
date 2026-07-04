import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// v4 Data & backup — mockup `#data`.
///
/// `.appbar` "Data & backup" h2.
/// `.card.list` 4 rows:
///   ☁️ Cloud backup (Pro) - .set switch (tapping opens paywall when off).
///   📄 Export data (JSON) - rowlink -> SnackBar "Exported JSON".
///   📊 Export data (CSV) - rowlink -> "Exported CSV".
///   🧹 Clear cache - rowlink -> "Cache cleared".
/// Footer 11 ink3 w600: "Local data is encrypted with SQLCipher."
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _cloudBackup = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar:
          const ContrastAppBar(title: 'Data & backup', showBackButton: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ext.lineColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A14142D),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Text('☁️', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          const Text.rich(
                            TextSpan(
                              text: 'Cloud backup ',
                              children: [
                                TextSpan(
                                  text: '(Pro)',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          AppSwitch(
                            value: _cloudBackup,
                            onChanged: (v) {
                              if (v) {
                                context.push('/paywall');
                              } else {
                                setState(() => _cloudBackup = false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _Rowlink(
                      emoji: '📄',
                      label: 'Export data (JSON) — coming soon',
                      onTap: () => _toast(context, 'Export JSON — coming soon'),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _Rowlink(
                      emoji: '📊',
                      label: 'Export data (CSV) — coming soon',
                      onTap: () => _toast(context, 'Export CSV — coming soon'),
                    ),
                    Container(height: 1, color: ext.lineColor),
                    _Rowlink(
                      emoji: '🧹',
                      label: 'Clear cache — coming soon',
                      onTap: () => _toast(context, 'Clear cache — coming soon'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Local data is encrypted with SQLCipher.',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ext.textFaint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext c, String msg) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Rowlink extends StatelessWidget {
  const _Rowlink({required this.emoji, required this.label, this.onTap});
  final String emoji;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text('›',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
