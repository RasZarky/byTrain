import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../domain/models/train.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isSelected;
  final String? heroTag;

  const TrainCard({
    super.key,
    required this.train,
    this.onTap,
    this.isLoading = false,
    this.isSelected = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDelayed = train.status.toLowerCase().contains('delayed');
    final statusColor = isDelayed ? Colors.orange : Colors.green;

    Widget cardContent = CustomCard(
      onTap: isLoading ? null : onTap,
      padding: EdgeInsets.zero,
      border: isSelected
          ? Border.all(color: theme.colorScheme.primary, width: 2)
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageOrIcon(theme, isNarrow ? 40 : 48),
                    const SizedBox(width: AppDimensions.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  train.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    fontSize: isNarrow ? 14 : 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s),
                              Text(
                                '#${train.number}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.m),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: _buildTimeBlock(
                                  theme,
                                  formatClockTimeString(train.departureTime),
                                  'Dep',
                                  isNarrow,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isNarrow
                                      ? AppDimensions.s
                                      : AppDimensions.m,
                                ),
                                child: Icon(
                                  Icons.east_rounded,
                                  size: isNarrow ? 14 : 16,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: _buildTimeBlock(
                                  theme,
                                  formatClockTimeString(train.arrivalTime),
                                  'Arr',
                                  isNarrow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.m,
                  vertical: AppDimensions.s + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.05)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.02),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppDimensions.radiusXL),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildStatusBadge(theme, statusColor)),
                    const SizedBox(width: AppDimensions.s),
                    _buildDetailsButton(theme, isNarrow),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: cardContent);
    }
    return cardContent;
  }

  Widget _buildImageOrIcon(ThemeData theme, double size) {
    final borderRadius = BorderRadius.circular(size * 0.3);

    if (train.imageUrl != null && train.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: train.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildIconContainer(theme, size),
          errorWidget: (context, url, error) =>
              _buildIconContainer(theme, size),
        ),
      );
    }

    return _buildIconContainer(theme, size);
  }

  Widget _buildIconContainer(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.train_rounded, color: Colors.white, size: size * 0.5),
    );
  }

  Widget _buildTimeBlock(
    ThemeData theme,
    String time,
    String label,
    bool isNarrow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            time,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: isNarrow ? 15 : 17,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: isNarrow ? 7 : 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                train.status.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsButton(ThemeData theme, bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isNarrow)
          Text(
            'Details',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (!isNarrow) const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
