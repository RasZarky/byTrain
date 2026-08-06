import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';

class LiveStatusCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Animation<double> pulseAnimation;
  final String? platform;

  const LiveStatusCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.pulseAnimation,
    this.platform,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.m),
      child: Row(
        children: [
          FadeTransition(
            opacity: pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.radio_button_checked, color: statusColor, size: 20),
            ),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  status.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: statusColor,
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
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
