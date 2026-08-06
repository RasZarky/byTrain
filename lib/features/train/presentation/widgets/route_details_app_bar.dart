import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/train.dart';

class RouteDetailsAppBar extends StatelessWidget {
  final Train train;

  const RouteDetailsAppBar({
    super.key,
    required this.train,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: Center(
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: const BackButton(color: Colors.white),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (train.imageUrl != null && train.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: train.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildDefaultBackground(theme),
                errorWidget: (context, url, error) => _buildDefaultBackground(theme),
              )
            else
              _buildDefaultBackground(theme),
            
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          train.type.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE ROUTE',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${train.name} #${train.number}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
            theme.colorScheme.secondary.withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}
