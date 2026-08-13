import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';

/// Static operational-status card. The app has no live tracking, so this just
/// shows the train's operational status from the timetable (e.g. "Running").
class LiveStatusCard extends StatelessWidget {
  final String status;
  final Color? statusColor;
  final String? platform;

  const LiveStatusCard({
    super.key,
    required this.status,
    this.statusColor,
    this.platform,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = statusColor ?? Colors.green;

    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.m),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operational Status',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  status.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (platform != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PLATFORM $platform',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
