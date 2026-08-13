import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      leading: Icon(icon, size: 22, color: colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        Icons.open_in_new_rounded,
        size: 16,
        color: colorScheme.onSurface.withValues(alpha: 0.2),
      ),
    );
  }
}
