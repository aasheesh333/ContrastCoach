import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavItem {
  const BottomNavItem({required this.label, required this.icon, required this.location});
  final String label;
  final IconData icon;
  final String location;
}

class ContrastBottomNav extends StatelessWidget {
  const ContrastBottomNav({super.key, required this.currentLocation, required this.onTap});

  final String currentLocation;
  final ValueChanged<String> onTap;

  static const List<BottomNavItem> items = [
    BottomNavItem(label: 'Home', icon: LucideIcons.house, location: '/home'),
    BottomNavItem(label: 'Streak', icon: LucideIcons.calendar, location: '/streak'),
    BottomNavItem(label: 'Insights', icon: LucideIcons.barChart, location: '/insights'),
  ];

  int get _currentIndex {
    final i = items.indexWhere((i) => currentLocation.startsWith(i.location));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(items[i].location),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          items[i].icon,
                          size: 20,
                          color: i == _currentIndex ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: i == _currentIndex ? cs.onSurface : cs.onSurfaceVariant,
                                fontWeight: i == _currentIndex ? FontWeight.w600 : FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
