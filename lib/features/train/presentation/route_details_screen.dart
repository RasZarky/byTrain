import 'package:flutter/material.dart';
import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/format.dart';
import '../domain/models/train.dart';
import 'widgets/live_status_card.dart';
import 'widgets/route_details_app_bar.dart';
import 'widgets/route_stop_tile.dart';
import 'widgets/section_title.dart';
import 'widgets/station_details_bottom_sheet.dart';

class RouteDetailsScreen extends StatefulWidget {
  final String routeId;
  final Train? train;

  const RouteDetailsScreen({super.key, required this.routeId, this.train});

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final PakRailRepository _repository = PakRailRepository();
  Train? _train;

  @override
  void initState() {
    super.initState();
    if (widget.train == null) {
      _loadTrain();
    }
  }

  Future<void> _loadTrain() async {
    final t = await _repository.trainById(widget.routeId);
    if (!mounted) return;
    setState(() => _train = t);
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
    // Use the passed train, the loaded repository train, or a loading state.
    final displayTrain =
        widget.train ??
        _train ??
        Train(
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final stop = displayTrain.stops[index];
                  return RouteStopTile(
                    stationName: stop.stationName,
                    arrivalTime: formatClockTimeString(stop.arrivalTime),
                    platform: stop.platform,
                    delay: stop.delay,
                    status: stop.status,
                    isFirst: index == 0,
                    isLast: index == displayTrain.stops.length - 1,
                    onTap: () => _showStationDetails(context, stop.stationName),
                  );
                }, childCount: displayTrain.stops.length),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxl)),
        ],
      ),
    );
  }
}
