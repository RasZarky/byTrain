import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';

class RouteDetailsScreen extends StatelessWidget {
  final String routeId;
  const RouteDetailsScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Route Details')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.m),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isLast = index == 9;
          final isFirst = index == 0;

          return IntrinsicHeight(
            child: Row(
              children: [
                _buildTimeline(theme, isFirst, isLast),
                const SizedBox(width: AppDimensions.m),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
                    child: CustomCard(
                      padding: const EdgeInsets.all(AppDimensions.m),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Station ${index + 1}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                if (index == 3)
                                  const Text(
                                    'Platform 2B',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${10 + index}:00 AM',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme, bool isFirst, bool isLast) {
    return Column(
      children: [
        if (!isFirst)
          Container(
            width: 2,
            height: AppDimensions.m,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          )
        else
          const SizedBox(height: AppDimensions.m),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: theme.colorScheme.primary.withValues(alpha:0.3),
            ),
          )
        else
          const SizedBox(height: AppDimensions.m),
      ],
    );
  }
}
