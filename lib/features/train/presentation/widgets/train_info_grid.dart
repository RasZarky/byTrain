import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/train.dart';

class TrainInfoGrid extends StatelessWidget {
  final Train train;

  const TrainInfoGrid({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppDimensions.m,
      crossAxisSpacing: AppDimensions.m,
      childAspectRatio: 2.5,
      children: [
        _InfoTile(
          icon: Icons.category_outlined,
          label: 'Type',
          value: train.type.name.toUpperCase(),
        ),
        const _InfoTile(
          icon: Icons.speed_rounded,
          label: 'Avg Speed',
          value: '85 km/h',
        ),
        const _InfoTile(
          icon: Icons.airline_seat_recline_extra,
          label: 'Capacity',
          value: '850 Seats',
        ),
        const _InfoTile(
          icon: Icons.wifi_rounded,
          label: 'Facilities',
          value: 'WiFi, Food',
        ),
      ],
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
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimensions.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
