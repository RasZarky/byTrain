import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.color,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isFullWidth ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.l,
              vertical: AppDimensions.m,
            ),
            decoration: _getBoxDecoration(theme, isDisabled),
            child: Center(
              child: widget.isLoading
                  ? _buildLoader(theme)
                  : _buildContent(theme, isDisabled),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(ThemeData theme, bool isDisabled) {
    final colorScheme = theme.colorScheme;
    final baseColor = widget.color ?? colorScheme.primary;

    if (isDisabled && widget.variant == AppButtonVariant.primary) {
      return BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      );
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColor, baseColor.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? colorScheme.outline.withValues(alpha: 0.2)
                : baseColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          color: Colors.transparent,
        );
    }
  }

  Widget _buildContent(ThemeData theme, bool isDisabled) {
    final colorScheme = theme.colorScheme;
    Color textColor;

    if (isDisabled) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      switch (widget.variant) {
        case AppButtonVariant.primary:
          textColor = colorScheme.onPrimary;
          break;
        case AppButtonVariant.secondary:
          textColor = colorScheme.onSecondary;
          break;
        case AppButtonVariant.outline:
        case AppButtonVariant.ghost:
          textColor = widget.color ?? colorScheme.primary;
          break;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: textColor),
          const SizedBox(width: AppDimensions.s),
        ],
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildLoader(ThemeData theme) {
    final color = widget.variant == AppButtonVariant.primary
        ? theme.colorScheme.onPrimary
        : (widget.color ?? theme.colorScheme.primary);
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
