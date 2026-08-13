import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/journey.dart';
import '../../domain/models/saved_journey.dart';
import 'journey_card.dart';

class ResultsSection extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;
  final List<Journey> journeys;
  final bool fastestRoute;
  final Set<String> savedKeys;
  final ValueChanged<Journey>? onSaveJourney;

  const ResultsSection({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.journeys,
    required this.fastestRoute,
    this.savedKeys = const {},
    this.onSaveJourney,
  });

  /// The journey with the shortest duration among the results (if any).
  Journey? get _fastest {
    Journey? best;
    for (final j in journeys) {
      if (best == null ||
          j.arrivalTime.difference(j.departureTime) <
              best.arrivalTime.difference(best.departureTime)) {
        best = j;
      }
    }
    return best;
  }

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
              return JourneyCard(
                journey: journey,
                isFastest: fastestRoute && identical(journey, _fastest),
                isSaved: savedKeys.contains(
                  SavedJourney.keyFor(journey.train.id, journey.departureTime),
                ),
                onSave: onSaveJourney == null
                    ? null
                    : () => onSaveJourney!(journey),
              );
            },
          ),
        ],
      ),
    );
  }
}
