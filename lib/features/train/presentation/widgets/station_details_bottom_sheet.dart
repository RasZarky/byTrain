import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'section_title.dart';

class StationDetailsBottomSheet extends StatelessWidget {
  final String stationName;

  const StationDetailsBottomSheet({
    super.key,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppDimensions.l),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stationName,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Central Station Hub',
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ZONE 1',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.l),
                        
                        // Gallery
                        SizedBox(
                          height: 180,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            children: [
                              _buildImageCard( "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmOiS7-Sgem2CGVSjv0Ge_-JNN_-df56Pn9DlhOrH6Zw&s=10",
                                  theme),
                              const SizedBox(width: AppDimensions.m),
                              _buildImageCard('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRy0uV9Q-dgvdP4qSclTjQjBrG71uYSPt3RfV3Rbl5jsA&s=10',
                                  theme),
                              const SizedBox(width: AppDimensions.m),
                              _buildImageCard('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIrRWpjCKZxlejQSlh8Bo-FT1VNhc6-PFfATMAZBbNkQ&s=10',
                                  theme),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppDimensions.xl),
                        
                        // Quick Stats
                        Row(
                          children: [
                            _buildStatItem(theme, Icons.train_outlined, '12', 'Platforms'),
                            const SizedBox(width: AppDimensions.m),
                            _buildStatItem(theme, Icons.accessible_forward_outlined, 'Yes', 'Step-free'),
                            const SizedBox(width: AppDimensions.m),
                            _buildStatItem(theme, Icons.timer_outlined, '24/7', 'Open'),
                          ],
                        ),
                        
                        const SizedBox(height: AppDimensions.xl),
                        const SectionTitle(title: 'STATION OVERVIEW'),
                        const SizedBox(height: AppDimensions.s),
                        Text(
                          'One of the busiest and most iconic stations in the region. Features a blend of classical architecture and ultra-modern passenger facilities.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        const SizedBox(height: AppDimensions.xl),
                        const SectionTitle(title: 'AMENITIES'),
                        const SizedBox(height: AppDimensions.m),
                        Wrap(
                          spacing: AppDimensions.s,
                          runSpacing: AppDimensions.s,
                          children: [
                            _buildFacilityChip(theme, Icons.wifi, 'Free Wi-Fi'),
                            _buildFacilityChip(theme, Icons.restaurant, 'Dining'),
                            _buildFacilityChip(theme, Icons.local_parking, 'Parking'),
                            _buildFacilityChip(theme, Icons.elevator, 'Lift Access'),
                            _buildFacilityChip(theme, Icons.shopping_bag_outlined, 'Retail'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl, ThemeData theme) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildFacilityChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
