import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/models/train.dart';
import 'widgets/live_status_card.dart';
import 'widgets/schedule_timeline.dart';
import 'widgets/section_title.dart';
import 'widgets/train_info_grid.dart';

class TrainDetailsScreen extends StatefulWidget {
  final String trainId;
  final Train? train;

  const TrainDetailsScreen({
    super.key,
    required this.trainId,
    this.train,
  });

  @override
  State<TrainDetailsScreen> createState() => _TrainDetailsScreenState();
}

class _TrainDetailsScreenState extends State<TrainDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late final Train train;

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

    // Use passed train or mock it based on ID
    train = widget.train ?? Train(
      id: widget.trainId,
      name: widget.trainId.length > 2 ? widget.trainId : 'Karakoram Express',
      number: '41UP',
      status: 'On Time',
      departureTime: '15:30',
      arrivalTime: '10:00',
      type: TrainType.express,
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
    final isDelayed = train.status.toLowerCase().contains('delayed');
    final statusColor = isDelayed ? Colors.orange : Colors.green;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LiveStatusCard(
                    status: train.status,
                    statusColor: statusColor,
                    pulseAnimation: _pulseAnimation,
                  ),
                  const SizedBox(height: AppDimensions.l),
                  const SectionTitle(title: 'JOURNEY DETAILS'),
                  const SizedBox(height: AppDimensions.m),
                  ScheduleTimeline(
                    departureStation: 'Lahore Junction',
                    departureTime: train.departureTime,
                    arrivalStation: 'Rawalpindi Station',
                    arrivalTime: train.arrivalTime,
                    duration: '4h 30m',
                  ),
                  const SizedBox(height: AppDimensions.l),
                  const SectionTitle(title: 'TRAIN INFORMATION'),
                  TrainInfoGrid(train: train),
                  const SizedBox(height: AppDimensions.xl),
                  AppButton(
                    label: 'View Full Route',
                    icon: Icons.map_outlined,
                    onPressed: () => context.push('/route-details/${widget.trainId}'),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image or Gradient
            if (train.imageUrl != null && train.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: train.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildDefaultBackground(theme),
                errorWidget: (context, url, error) => _buildDefaultBackground(theme),
              )
            else
              _buildDefaultBackground(theme),
            
            // Overlay for better text readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Header Content
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'train-icon-${widget.trainId}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.train_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    train.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Train Number: #${train.number}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
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
            theme.colorScheme.primary.withValues(alpha: 0.6),
            theme.colorScheme.secondary.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Opacity(
        opacity: 0.1,
        child: Icon(Icons.train, size: 300, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
