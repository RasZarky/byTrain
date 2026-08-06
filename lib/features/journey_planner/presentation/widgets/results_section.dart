import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/journey.dart';
import 'journey_card.dart';

class ResultsSection extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;
  final List<Journey> journeys;
  final bool fastestRoute;
  final bool cheapestFirst;

  const ResultsSection({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.journeys,
    required this.fastestRoute,
    required this.cheapestFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED ROUTES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${journeys.length} routes found',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.m),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: journeys.length,
            itemBuilder: (context, index) {
              final journey = journeys[index];
              // Simplified logic for tagging fastest/cheapest in the list
              return JourneyCard(
                journey: journey,
                isFastest: fastestRoute && index == 0, // Placeholder logic
                isCheapest: cheapestFirst && index == 0, // Placeholder logic
              );
            },
          ),
        ],
      ),
    );
  }
}
