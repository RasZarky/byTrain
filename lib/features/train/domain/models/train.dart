import 'package:equatable/equatable.dart';

enum TrainType { express, regional, local }

class Train extends Equatable {
  final String id;
  final String name;
  final String number;
  final String status;
  final String departureTime;
  final String arrivalTime;
  final TrainType type;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  const Train({
    required this.id,
    required this.name,
    required this.number,
    required this.status,
    required this.departureTime,
    required this.arrivalTime,
    this.type = TrainType.regional,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        number,
        status,
        departureTime,
        arrivalTime,
        type,
        latitude,
        longitude,
        imageUrl,
      ];
}
