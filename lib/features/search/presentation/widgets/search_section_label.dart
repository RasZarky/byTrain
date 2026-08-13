import 'package:flutter/material.dart';

class SearchSectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const SearchSectionLabel({super.key, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
