import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_dimensions.dart';

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: title,
      button: onTap != null,
      child: ListTile(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.m,
          vertical: AppDimensions.xs,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.s),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              size: 14,
            ),
      ),
    );
  }
}
