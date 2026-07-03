import 'dart:ui';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_motion.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavItem {
  const BottomNavItem({required this.label, required this.icon, required this.location});
  final String label;
  final IconData icon;
  final String location;
}

/// v4 tab bar. Matches the mockup `.tabbar` token:
///   82px tall, `color-mix(in srgb, var(--card) 88%, transparent)` bg,
///   `backdrop-filter: blur(14px)`, 1px top border (--line),
///   `padding-bottom: 16px` (i.e. the bottom 16px is home-indicator safe area).
///   Items: column gap 4, 23×23 stroke icon (no fill), ink3 inactive / heat active,
///   label 11/w600, 12px radius press target with `.88` active scale.
///   No underline indicator — active state is color-only (matches mockup).
class ContrastBottomNav extends StatelessWidget {
  const ContrastBottomNav({super.key, required this.currentLocation, required this.onTap});

  final String currentLocation;
  final ValueChanged<String> onTap;

  static const List<BottomNavItem> items = [
    BottomNavItem(label: 'Home', icon: LucideIcons.house, location: '/home'),
    BottomNavItem(label: 'Explore', icon: LucideIcons.search, location: '/explore'),
    BottomNavItem(label: 'Insights', icon: LucideIcons.barChart3, location: '/insights'),
    BottomNavItem(label: 'Coach', icon: LucideIcons.messageCircle, location: '/coach'),
    BottomNavItem(label: 'You', icon: LucideIcons.user, location: '/settings'),
  ];

  int get _currentIndex {
    final i = items.indexWhere((i) => currentLocation.startsWith(i.location));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lineColor = Theme.of(context).extension<AppColorsExtension>()!.lineColor;
    final cardColor = cs.surface;

    // 88% opacity card color (color-mix(in srgb, var(--card) 88%, transparent)).
    final railColor = cardColor.withOpacity(0.88);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: railColor,
            border: Border(top: BorderSide(color: lineColor, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _Tab(
                        item: items[i],
                        selected: i == _currentIndex,
                        onTap: () => onTap(items[i].location),
                        activeColor: AppColors.heat,
                        inactiveColor: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? widget.activeColor : widget.inactiveColor;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: widget.item.label,
        button: true,
        selected: widget.selected,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: AppCurves.spring,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.house == widget.item.icon
                      ? widget.item.icon
                      : widget.item.icon,
                    size: 23,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
