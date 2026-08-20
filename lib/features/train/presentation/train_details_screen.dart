import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/app_button.dart';
import '../domain/models/train.dart';
import 'widgets/live_status_card.dart';
import 'widgets/schedule_timeline.dart';
import 'widgets/section_title.dart';
import 'widgets/train_info_grid.dart';

class TrainDetailsScreen extends StatefulWidget {
  final String trainId;
  final Train? train;

  const TrainDetailsScreen({super.key, required this.trainId, this.train});

  @override
  State<TrainDetailsScreen> createState() => _TrainDetailsScreenState();
}

class _TrainDetailsScreenState extends State<TrainDetailsScreen> {
  final PakRailRepository _repository = PakRailRepository();
  Train? _train;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Use the passed train, or load the real one from the bundled dataset.
    _train = widget.train;
    if (_train == null) {
      _loadTrain();
    }
  }

  Future<void> _loadTrain() async {
    setState(() => _loading = true);
    final t = await _repository.trainById(widget.trainId);
    if (!mounted) return;
    setState(() {
      _train = t;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final train = _train;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(theme, train),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: _buildBody(theme, train),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, Train? train) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: AppDimensions.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (train == null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppDimensions.xxl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: AppDimensions.m),
              Text(
                'Train not found in the current timetable',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDelayed = train.status.toLowerCase().contains('delayed');
    final statusColor = isDelayed ? Colors.orange : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiveStatusCard(status: train.status, statusColor: statusColor),
        const SizedBox(height: AppDimensions.l),
        const SectionTitle(title: 'JOURNEY DETAILS'),
        const SizedBox(height: AppDimensions.m),
        ScheduleTimeline(
          departureStation: train.stops.isNotEmpty
              ? train.stops.first.stationName
              : 'Origin',
          departureTime: formatClockTimeString(train.departureTime),
          arrivalStation: train.stops.isNotEmpty
              ? train.stops.last.stationName
              : 'Destination',
          arrivalTime: formatClockTimeString(train.arrivalTime),
          duration: train.durationMin != null
              ? formatDuration(train.durationMin!)
              : 'Unknown',
        ),
        const SizedBox(height: AppDimensions.l),
        const SectionTitle(title: 'TRAIN INFORMATION'),
        TrainInfoGrid(train: train),
        const SizedBox(height: AppDimensions.xl),
        AppButton(
          label: 'View Full Route',
          icon: Icons.route_rounded,
          onPressed: () =>
              context.push('/route-details/${widget.trainId}', extra: train),
        ),
        const SizedBox(height: AppDimensions.xxl),
      ],
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, Train? train) {
    final imageUrl = train?.imageUrl;
    return SliverAppBar(
      expandedHeight: 220,
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
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image or Gradient
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildDefaultBackground(theme),
                errorWidget: (context, url, error) =>
                    _buildDefaultBackground(theme),
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
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.train_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    train?.name ?? widget.trainId,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Train Number: #${train?.number ?? widget.trainId}',
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
