import 'package:flutter/material.dart';

class SearchSheetHeader extends StatelessWidget {
  final bool isSearching;
  final Animation<double>? pulseAnimation;

  const SearchSheetHeader({
    super.key,
    required this.isSearching,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ).createShader(bounds),
          child: Text(
            isSearching ? 'Search Results' : 'Explore Trains',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
          ),
        ),
      ],
    );
  }
}
