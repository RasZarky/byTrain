import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/format.dart';
import '../../domain/models/train.dart';

class TrainInfoGrid extends StatelessWidget {
  final Train train;

  const TrainInfoGrid({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimensions.m;
        final width = constraints.maxWidth;
        final isWide = width > 600;

        // Use 2 columns on mobile, 3 on tablets/wider screens for short info
        final shortTileWidth = isWide
            ? (width - 2 * spacing) / 3
            : (width - spacing) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: shortTileWidth,
                  child: _InfoTile(
                    icon: Icons.category_outlined,
                    label: 'Type',
                    value: train.type.name.toUpperCase(),
                  ),
                ),
                SizedBox(
                  width: shortTileWidth,
                  child: _InfoTile(
                    icon: Icons.departure_board_rounded,
                    label: 'Stops',
                    value: '${train.stops.length}',
                  ),
                ),
                if (train.durationMin != null)
                  SizedBox(
                    width: shortTileWidth,
                    child: _InfoTile(
                      icon: Icons.schedule_rounded,
                      label: 'Duration',
                      value: formatDuration(train.durationMin!),
                    ),
                  ),
              ],
            ),
            if (train.stops.isNotEmpty) ...[
              const SizedBox(height: spacing),
              _InfoTile(
                icon: Icons.route_rounded,
                label: 'Route',
                value:
                    '${train.stops.first.stationName} → ${train.stops.last.stationName}',
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimensions.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 9,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
