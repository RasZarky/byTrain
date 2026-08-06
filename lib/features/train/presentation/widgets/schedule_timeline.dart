import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';

class ScheduleTimeline extends StatelessWidget {
  final String departureStation;
  final String departureTime;
  final String arrivalStation;
  final String arrivalTime;
  final String duration;

  const ScheduleTimeline({
    super.key,
    required this.departureStation,
    required this.departureTime,
    required this.arrivalStation,
    required this.arrivalTime,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.l),
      child: Column(
        children: [
          _buildTimelineItem(
            theme,
            departureStation,
            departureTime,
            'Scheduled Departure',
            true,
            false,
          ),
          _buildTimelineItem(
            theme,
            'Duration: $duration',
            '',
            'In Transit',
            false,
            true,
            isMiddle: true,
          ),
          _buildTimelineItem(
            theme,
            arrivalStation,
            arrivalTime,
            'Estimated Arrival',
            false,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ThemeData theme,
    String title,
    String time,
    String subtitle,
    bool isFirst,
    bool isLast, {
    bool isMiddle = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isMiddle ? Colors.transparent : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 4,
                  ),
                ),
                child: isMiddle
                    ? Icon(Icons.more_vert,
                        size: 12, color: theme.colorScheme.primary.withValues(alpha: 0.3))
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.l),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isMiddle ? FontWeight.normal : FontWeight.w800,
                            color: isMiddle ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
