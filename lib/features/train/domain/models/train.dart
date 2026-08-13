import 'package:equatable/equatable.dart';

enum TrainType { express, regional, local }

enum StopStatus { passed, current, upcoming }

class TrainStop extends Equatable {
  final String stationName;
  final String arrivalTime;
  final String? departureTime;
  final String? platform;
  final String? delay;
  final StopStatus status;

  const TrainStop({
    required this.stationName,
    required this.arrivalTime,
    this.departureTime,
    this.platform,
    this.delay,
    required this.status,
  });

  @override
  List<Object?> get props => [
    stationName,
    arrivalTime,
    departureTime,
    platform,
    delay,
    status,
  ];
}

class Train extends Equatable {
  final String id;
  final String name;
  final String number;
  final String status;
  final String departureTime;
  final String arrivalTime;
  final int? durationMin;
  final TrainType type;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<TrainStop> stops;

  const Train({
    required this.id,
    required this.name,
    required this.number,
    required this.status,
    required this.departureTime,
    required this.arrivalTime,
    this.durationMin,
    this.type = TrainType.regional,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.stops = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    number,
    status,
    departureTime,
    arrivalTime,
    durationMin,
    type,
    latitude,
    longitude,
    imageUrl,
    stops,
  ];
}
