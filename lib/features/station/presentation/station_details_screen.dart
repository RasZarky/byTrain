import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/custom_card.dart';
import '../../train/domain/models/train.dart';
import '../domain/models/station.dart';

enum _StationBoard { menu, arrivals, departures }

class StationDetailsScreen extends StatefulWidget {
  final String stationId;
  const StationDetailsScreen({super.key, required this.stationId});

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  final PakRailRepository _repository = PakRailRepository();

  Station? _station;
  List<Train> _trains = const [];
  bool _loading = true;
  String? _error;
  _StationBoard _board = _StationBoard.menu;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final station = await _repository.stationById(widget.stationId);
      final trains = await _repository.trainsThroughStation(widget.stationId);
      if (!mounted) return;
      setState(() {
        _station = station;
        _trains = trains;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_station?.name ?? 'Station Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Text(
                  'Could not load station: $_error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            )
          : _station == null
          ? Center(
              child: Text(
                'Station not found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final station = _station!;
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.m),
      children: [
        CustomCard(
          padding: const EdgeInsets.all(AppDimensions.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (station.code.isNotEmpty)
                          Text(
                            'Station code: ${station.code}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (station.city.isNotEmpty || station.province.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.m),
                Text(
                  [
                    if (station.city.isNotEmpty) station.city,
                    if (station.province.isNotEmpty) station.province,
                  ].join(', '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.l),
        if (_board == _StationBoard.menu)
          _buildMenu(theme)
        else
          ..._buildBoard(theme, station),
      ],
    );
  }

  Widget _buildMenu(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CHOOSE A BOARD',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppDimensions.m),
        _BoardOptionCard(
          icon: Icons.south_west_rounded,
          title: 'Arrival',
          subtitle: 'Trains coming into this station',
          onTap: () => setState(() => _board = _StationBoard.arrivals),
        ),
        const SizedBox(height: AppDimensions.s),
        _BoardOptionCard(
          icon: Icons.north_east_rounded,
          title: 'Departure',
          subtitle: 'Trains leaving this station',
          onTap: () => setState(() => _board = _StationBoard.departures),
        ),
      ],
    );
  }

  List<Widget> _buildBoard(ThemeData theme, Station station) {
    final isArrivals = _board == _StationBoard.arrivals;
    final entries = isArrivals
        ? _arrivalsAt(station)
        : _departuresFrom(station);
    final colorScheme = theme.colorScheme;

    return [
      Row(
        children: [
          IconButton(
            tooltip: 'Back to options',
            onPressed: () => setState(() => _board = _StationBoard.menu),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              isArrivals ? 'ARRIVALS' : 'DEPARTURES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.s),
      if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
          child: Center(
            child: Text(
              isArrivals
                  ? 'No trains arriving at this station in the current timetable'
                  : 'No trains departing this station in the current timetable',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        )
      else
        for (final entry in entries)
          _buildTrainTile(theme, entry, isArrivals),
    ];
  }

  List<_StationTrain> _arrivalsAt(Station station) {
    final result = <_StationTrain>[];
    for (final train in _trains) {
      final index = _stopIndex(train, station);
      if (index <= 0) continue;
      result.add(
        _StationTrain(
          train: train,
          stop: train.stops[index],
          fromOrTo: train.stops[index - 1].stationName,
          originOrDestination: train.stops.first.stationName,
        ),
      );
    }
    result.sort(
      (a, b) => _minutes(a.stop.arrivalTime).compareTo(
        _minutes(b.stop.arrivalTime),
      ),
    );
    return result;
  }

  List<_StationTrain> _departuresFrom(Station station) {
    final result = <_StationTrain>[];
    for (final train in _trains) {
      final index = _stopIndex(train, station);
      if (index < 0 || index >= train.stops.length - 1) continue;
      result.add(
        _StationTrain(
          train: train,
          stop: train.stops[index],
          fromOrTo: train.stops[index + 1].stationName,
          originOrDestination: train.stops.last.stationName,
        ),
      );
    }
    result.sort((a, b) {
      final aTime = a.stop.departureTime ?? a.stop.arrivalTime;
      final bTime = b.stop.departureTime ?? b.stop.arrivalTime;
      return _minutes(aTime).compareTo(_minutes(bTime));
    });
    return result;
  }

  int _stopIndex(Train train, Station station) {
    return train.stops.indexWhere((s) => s.stationName == station.name);
  }

  int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  Widget _buildTrainTile(
    ThemeData theme,
    _StationTrain entry,
    bool isArrival,
  ) {
    final colorScheme = theme.colorScheme;
    final time = isArrival
        ? entry.stop.arrivalTime
        : (entry.stop.departureTime ?? entry.stop.arrivalTime);
    final directionLabel = isArrival
        ? 'From ${entry.fromOrTo}'
        : 'To ${entry.fromOrTo}';
    final endpointLabel = isArrival
        ? 'Origin ${entry.originOrDestination}'
        : 'Towards ${entry.originOrDestination}';

    return CustomCard(
      onTap: () =>
          context.push('/train-details/${entry.train.id}', extra: entry.train),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isArrival ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          entry.train.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '#${entry.train.number} · $directionLabel · $endpointLabel',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          formatClockTimeString(time),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _StationTrain {
  final Train train;
  final TrainStop stop;
  final String fromOrTo;
  final String originOrDestination;

  const _StationTrain({
    required this.train,
    required this.stop,
    required this.fromOrTo,
    required this.originOrDestination,
  });
}

class _BoardOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BoardOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.l),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(width: AppDimensions.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
