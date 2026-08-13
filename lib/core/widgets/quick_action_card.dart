import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

class QuickActionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard>
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
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(minHeight: 110),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: widget.color.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              child: Stack(
                children: [
                  // Subtle gradient accent
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Large decorative background icon
                  Positioned(
                    right: -15,
                    bottom: -15,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        widget.icon,
                        size: 90,
                        color: widget.color.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon bubble
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: AppDimensions.iconM,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s),
                        // Bold, modern label
                        Text(
                          widget.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
