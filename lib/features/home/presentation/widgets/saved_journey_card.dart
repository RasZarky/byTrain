import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../journey_planner/domain/models/saved_journey.dart';

class SavedJourneyCard extends StatelessWidget {
  final SavedJourney journey;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SavedJourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dep = DateFormat('EEE, d MMM · HH:mm').format(journey.departureTime);
    final depTime = DateFormat('HH:mm').format(journey.departureTime);
    final arrTime = DateFormat('HH:mm').format(journey.arrivalTime);
    final duration = journey.arrivalTime.difference(journey.departureTime);

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.train_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.m),
                Expanded(
                  child: Text(
                    journey.trainName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '#${journey.trainNumber}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.m),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        depTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        journey.fromName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s,
                  ),
                  child: Icon(
                    Icons.east_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        journey.toName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.m),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  'Departs $dep · ${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove from saved journeys',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.bookmark_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
