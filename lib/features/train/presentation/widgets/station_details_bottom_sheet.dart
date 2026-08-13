import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/pakrail_repository.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../station/domain/models/station.dart';
import '../../domain/models/train.dart';
import 'section_title.dart';

class StationDetailsBottomSheet extends StatefulWidget {
  final String stationName;

  const StationDetailsBottomSheet({super.key, required this.stationName});

  @override
  State<StationDetailsBottomSheet> createState() =>
      _StationDetailsBottomSheetState();
}

class _StationDetailsBottomSheetState extends State<StationDetailsBottomSheet> {
  final PakRailRepository _repository = PakRailRepository();

  Station? _station;
  List<Train> _trains = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final station = await _repository.stationByName(widget.stationName);
    final trains = station == null
        ? const <Train>[]
        : await _repository.trainsThroughStation(station.id);
    if (!mounted) return;
    setState(() {
      _station = station;
      _trains = trains;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppDimensions.l),
                        children: _buildContent(theme),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final station = _station;

    if (station == null) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Text(
              'Station not found in the current dataset',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (station.code.isNotEmpty)
                  Text(
                    'Station code: ${station.code}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                if (station.city.isNotEmpty || station.province.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          [
                            if (station.city.isNotEmpty) station.city,
                            if (station.province.isNotEmpty) station.province,
                          ].join(', '),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.m),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/station-details/${station.id}'),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Station Page'),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.l),
      const SectionTitle(title: 'TRAINS AT THIS STATION'),
      const SizedBox(height: AppDimensions.m),
      if (_trains.isEmpty)
        Text(
          'No trains call at this station in the current timetable.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        )
      else
        for (final train in _trains) _buildTrainTile(theme, train, station),
    ];
  }

  Widget _buildTrainTile(ThemeData theme, Train train, Station station) {
    final colorScheme = theme.colorScheme;
    TrainStop? stopAtStation;
    for (final s in train.stops) {
      if (s.stationName == station.name) {
        stopAtStation = s;
        break;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.train_rounded, size: 18, color: colorScheme.primary),
      ),
      title: Text(
        train.name,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
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
          ? Text(
              'Arr ${stopAtStation.arrivalTime}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            )
          : null,
      onTap: () => context.push('/train-details/${train.id}', extra: train),
    );
  }
}
