import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

class SearchFilterBar extends StatelessWidget {
  final String selectedContentFilter;
  final ValueChanged<String> onContentFilterSelected;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final bool showClassFilter;

  const SearchFilterBar({
    super.key,
    required this.selectedContentFilter,
    required this.onContentFilterSelected,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.showClassFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const contentFilters = ['All', 'Trains', 'Stations', 'Routes'];
    const classFilters = ['All', 'Express', 'Regional', 'Local'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipRow(
          theme: theme,
          filters: contentFilters,
          selected: selectedContentFilter,
          onSelected: onContentFilterSelected,
        ),
        if (showClassFilter) ...[
          const SizedBox(height: 8),
          _ChipRow(
            theme: theme,
            filters: classFilters,
            selected: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ],
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  final ThemeData theme;
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChipRow({
    required this.theme,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final bool isSelected = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (_) => onSelected(f),
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              checkmarkColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
