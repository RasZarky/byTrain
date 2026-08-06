import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'recent_search_card.dart';

class RecentSearchesSection extends StatelessWidget {
  final List<Map<String, String>> recentSearches;
  final VoidCallback onClearAll;
  final Function(String, String) onSearchSelected;

  const RecentSearchesSection({
    super.key,
    required this.recentSearches,
    required this.onClearAll,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SEARCHES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            if (recentSearches.isNotEmpty)
              TextButton(
                onPressed: () {
                  onClearAll();
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  'Clear All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.s),
        if (recentSearches.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  Text(
                    'No recent searches yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSearches.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.s),
            itemBuilder: (context, index) {
              final search = recentSearches[index];
              return RecentSearchCard(
                from: search['from']!,
                to: search['to']!,
                onTap: () => onSearchSelected(search['from']!, search['to']!),
              );
            },
          ),
      ],
    );
  }
}
