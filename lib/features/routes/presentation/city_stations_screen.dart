import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/pakrail_repository.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/custom_card.dart';
import '../../station/domain/models/city.dart';
import '../../station/domain/models/station.dart';

class CityStationsScreen extends StatefulWidget {
  final String cityName;

  const CityStationsScreen({super.key, required this.cityName});

  @override
  State<CityStationsScreen> createState() => _CityStationsScreenState();
}

class _CityStationsScreenState extends State<CityStationsScreen> {
  final PakRailRepository _repository = PakRailRepository();

  City? _city;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final city = await _repository.cityByName(widget.cityName);
      if (!mounted) return;
      setState(() {
        _city = city;
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
    final city = _city;

    return Scaffold(
      appBar: AppBar(
        title: Text(city?.name ?? widget.cityName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Text(
                  'Could not load stations: $_error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            )
          : city == null
          ? Center(
              child: Text(
                'City not found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : _StationsList(city: city),
    );
  }
}

class _StationsList extends StatelessWidget {
  final City city;

  const _StationsList({required this.city});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.m,
        AppDimensions.s,
        AppDimensions.m,
        100,
      ),
      itemCount: city.stations.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final count = city.stations.length;
          return Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: AppDimensions.m,
              top: AppDimensions.s,
            ),
            child: Text(
              city.province.isNotEmpty
                  ? '${city.province} · $count ${count == 1 ? 'station' : 'stations'}'
                  : '$count ${count == 1 ? 'station' : 'stations'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          );
        }

        final station = city.stations[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.s),
          child: _StationTile(
            station: station,
            onTap: () => context.push('/station-details/${station.id}'),
          ),
        );
      },
    );
  }
}

class _StationTile extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const _StationTile({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
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
        title: Text(
          station.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: station.code.isNotEmpty
            ? Text(
                'Station ${station.code}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
