import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../domain/models/journey.dart';

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final bool isFastest;
  final bool isCheapest;

  const JourneyCard({
    super.key,
    required this.journey,
    this.isFastest = false,
    this.isCheapest = false,
  });

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fromTime = DateFormat('HH:mm').format(journey.departureTime);
    final toTime = DateFormat('HH:mm').format(journey.arrivalTime);
    final duration = _formatDuration(journey.departureTime, journey.arrivalTime);

    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: (isFastest || isCheapest)
                ? Border(
                    left: BorderSide(
                      color: isFastest ? colorScheme.primary : colorScheme.secondary,
                      width: 5,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.m),
            child: Column(
              children: [
                // Top Tags Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isFastest)
                          _JourneyTag(
                            label: 'FASTEST',
                            icon: Icons.bolt_rounded,
                            bg: colorScheme.primary.withValues(alpha: 0.1),
                            text: colorScheme.primary,
                          ),
                        if (isCheapest)
                          _JourneyTag(
                            label: 'CHEAPEST',
                            icon: Icons.savings_rounded,
                            bg: colorScheme.secondary.withValues(alpha: 0.1),
                            text: colorScheme.onSecondaryFixedVariant,
                          ),
                        if (!isFastest && !isCheapest)
                          Text(
                            journey.train.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              letterSpacing: 1.0,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      duration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.m),

                // Station route details with timing
                Row(
                  children: [
                    // Visual map connectors
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppDimensions.m),

                    // Station departures & arrivals text
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$fromTime • ${journey.from.name.split(' ').first}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                journey.train.status, // Assuming platform info might be here or status
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$toTime • ${journey.to.name.split(' ').first}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Direct', // Simplified for now
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.m),
                // Bottom CTA & Pricing info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_train_rounded,
                          size: 16,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: AppDimensions.xs),
                        Text(
                          journey.train.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Rs. ${journey.price.toInt()}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color text;

  const _JourneyTag({
    required this.label,
    required this.icon,
    required this.bg,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: AppDimensions.s),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
