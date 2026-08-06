import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../home/presentation/bloc/home_bloc.dart';
import '../domain/models/train.dart';
import 'widgets/live_status_card.dart';
import 'widgets/route_details_app_bar.dart';
import 'widgets/route_stop_tile.dart';
import 'widgets/section_title.dart';
import 'widgets/station_details_bottom_sheet.dart';

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showStationDetails(BuildContext context, String stationName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationDetailsBottomSheet(stationName: stationName),
    );
  }

  @override
  Widget build(BuildContext context) {

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
          RouteDetailsAppBar(train: displayTrain),
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
                      onTap: () => _showStationDetails(context, stop.stationName),
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
}
