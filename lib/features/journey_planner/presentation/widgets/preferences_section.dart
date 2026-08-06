import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'preference_chip.dart';

class PreferencesSection extends StatelessWidget {
  final bool fastestRoute;
  final bool directOnly;
  final bool cheapestFirst;
  final VoidCallback onFastestRouteToggle;
  final VoidCallback onDirectOnlyToggle;
  final VoidCallback onCheapestFirstToggle;

  const PreferencesSection({
    super.key,
    required this.fastestRoute,
    required this.directOnly,
    required this.cheapestFirst,
    required this.onFastestRouteToggle,
    required this.onDirectOnlyToggle,
    required this.onCheapestFirstToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'TRAVEL PREFERENCES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              PreferenceChip(
                icon: Icons.bolt_rounded,
                label: 'Fastest Route',
                isSelected: fastestRoute,
                onTap: onFastestRouteToggle,
              ),
              const SizedBox(width: AppDimensions.s),
              PreferenceChip(
                icon: Icons.directions_railway_rounded,
                label: 'Direct Only',
                isSelected: directOnly,
                onTap: onDirectOnlyToggle,
              ),
              const SizedBox(width: AppDimensions.s),
              PreferenceChip(
                icon: Icons.savings_rounded,
                label: 'Cheapest First',
                isSelected: cheapestFirst,
                onTap: onCheapestFirstToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
