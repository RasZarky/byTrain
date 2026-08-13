import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';
import '../../train/domain/models/train.dart';
import '../domain/models/station.dart';

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

        Text(
          'TRAINS AT THIS STATION',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppDimensions.m),

        if (_trains.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
            child: Center(
              child: Text(
                'No trains call at this station in the current timetable',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          for (final train in _trains) _buildTrainTile(theme, train, station),
      ],
    );
  }

  Widget _buildTrainTile(ThemeData theme, Train train, Station station) {
    TrainStop? stopAtStation;
    for (final s in train.stops) {
      if (s.stationName == station.name) {
        stopAtStation = s;
        break;
      }
    }
    final colorScheme = theme.colorScheme;

    return CustomCard(
      onTap: () => context.push('/train-details/${train.id}', extra: train),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.train_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          train.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '#${train.number}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        trailing: stopAtStation != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Arr ${stopAtStation.arrivalTime}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Dep ${stopAtStation.departureTime ?? stopAtStation.arrivalTime}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
