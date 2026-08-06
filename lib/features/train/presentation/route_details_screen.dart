import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../home/presentation/bloc/home_bloc.dart';
import '../domain/models/train.dart';
import 'widgets/live_status_card.dart';
import 'widgets/route_stop_tile.dart';
import 'widgets/section_title.dart';

class RouteDetailsScreen extends StatefulWidget {
  final String routeId;
  final Train? train;

  const RouteDetailsScreen({
    super.key,
    required this.routeId,
    this.train,
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Try to find the train in HomeBloc state if not passed directly
    Train? trainFromBloc;
    final homeState = context.read<HomeBloc>().state;
    if (homeState is HomeLoaded) {
      try {
        trainFromBloc = homeState.recentTrains.firstWhere((t) => t.id == widget.routeId);
      } catch (_) {
        trainFromBloc = null;
      }
    }

    // Use passed train, then Bloc train, then minimal fallback
    final displayTrain = widget.train ?? trainFromBloc ?? Train(
      id: widget.routeId,
      name: 'Train Details',
      number: '---',
      status: 'Loading...',
      departureTime: '--:--',
      arrivalTime: '--:--',
      type: TrainType.local,
      stops: const [
        TrainStop(
          stationName: 'Loading Route...',
          arrivalTime: '--:--',
          status: StopStatus.passed,
        ),
      ],
    );

    final isDelayed = displayTrain.status.toLowerCase().contains('delayed');
    final statusColor = isDelayed ? Colors.orange : Colors.green;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme, displayTrain),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LiveStatusCard(
                    status: displayTrain.status,
                    statusColor: statusColor,
                    pulseAnimation: _pulseAnimation,
                  ),
                  const SizedBox(height: AppDimensions.l),
                  const SectionTitle(title: 'STOPS & TIMELINE'),
                ],
              ),
            ),
          ),
          if (displayTrain.stops.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final stop = displayTrain.stops[index];
                    return RouteStopTile(
                      stationName: stop.stationName,
                      arrivalTime: stop.arrivalTime,
                      platform: stop.platform,
                      delay: stop.delay,
                      status: stop.status,
                      isFirst: index == 0,
                      isLast: index == displayTrain.stops.length - 1,
                    );
                  },
                  childCount: displayTrain.stops.length,
                ),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, Train train) {
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
