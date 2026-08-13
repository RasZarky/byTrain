import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

class SearchingLoader extends StatelessWidget {
  const SearchingLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppDimensions.m),
            Text(
              'Searching timetables...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Matching trains on the selected date',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
