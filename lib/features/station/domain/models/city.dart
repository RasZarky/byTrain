import 'package:equatable/equatable.dart';

import 'station.dart';

/// Group of stations that share a [name] (from [Station.city]).
class City extends Equatable {
  final String name;
  final String province;
  final List<Station> stations;

  const City({
    required this.name,
    this.province = '',
    this.stations = const [],
  });

  @override
  List<Object?> get props => [name, province, stations];
}
