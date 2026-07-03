import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_motion.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkInk.withOpacity(0.25)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(items[i].location),
                    child: Semantics(
                      label: items[i].label,
                      button: true,
                      selected: i == _currentIndex,
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppMotion.defaultDuration,
                          curve: AppCurves.spring,
                          child: Icon(
                            items[i].icon,
                            size: i == _currentIndex ? 26 : 24,
                            color: i == _currentIndex
                                ? AppColors.heat
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: AppMotion.defaultDuration,
                          curve: AppCurves.spring,
                          width: i == _currentIndex ? 20 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: i == _currentIndex
                                ? AppColors.heat
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: i == _currentIndex
                                    ? AppColors.heat
                                    : cs.onSurfaceVariant,
                                fontWeight: i == _currentIndex
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ],
                    ),
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
