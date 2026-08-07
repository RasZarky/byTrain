import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64, // Space for icon + padding to align text
      endIndent: AppDimensions.m,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }
}
