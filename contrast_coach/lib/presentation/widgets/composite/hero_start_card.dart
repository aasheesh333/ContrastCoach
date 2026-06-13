import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroStartCard extends StatelessWidget {
  const HeroStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      elevation: AppCardElevation.high,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('READY', style: tt.labelSmall),
          const SizedBox(height: 8),
          Text('Start session', style: tt.displayMedium),
          const SizedBox(height: 24),
          AppButton(
            label: 'Begin',
            onPressed: () => context.push('/session'),
          ),
        ],
      ),
    );
  }
}
