import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../domain/models/train.dart';

class RouteStopTile extends StatelessWidget {
  final String stationName;
  final String arrivalTime;
  final String? departureTime;
  final String? platform;
  final String? delay;
  final StopStatus status;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const RouteStopTile({
    super.key,
    required this.stationName,
    required this.arrivalTime,
    this.departureTime,
    this.platform,
    this.delay,
    required this.status,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = status == StopStatus.current;
    final isPassed = status == StopStatus.passed;

    return IntrinsicHeight(
      child: Row(
        children: [
          _buildTimeline(theme, isCurrent, isPassed),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
              child: CustomCard(
                onTap: onTap,
                padding: const EdgeInsets.all(AppDimensions.m),
                border: isCurrent
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
                color: isPassed
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      )
                    : theme.colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stationName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isPassed
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    )
                                  : null,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (platform != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PLAT $platform',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'AT STATION',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrivalTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isPassed
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (delay != null)
                          Text(
                            delay!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme, bool isCurrent, bool isPassed) {
    final color = isPassed
        ? theme.colorScheme.primary.withValues(alpha: 0.3)
        : theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 2,
          height: AppDimensions.m,
          color: isFirst
              ? Colors.transparent
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
        if (isCurrent)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.train, size: 12, color: Colors.white),
          )
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isPassed ? Colors.transparent : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: isPassed
                ? Icon(Icons.check_circle, size: 16, color: color)
                : null,
          ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          )
        else
          const SizedBox(height: AppDimensions.m),
      ],
    );
  }
}
