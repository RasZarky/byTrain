import 'package:equatable/equatable.dart';
import '../../../station/domain/models/station.dart';
import '../../../train/domain/models/train.dart';

class Journey extends Equatable {
  final Station from;
  final Station to;
  final Train train;
  final DateTime departureTime;
  final DateTime arrivalTime;

  /// Fare in Pakistani rupees. Null when no verified fare data is available
  /// (Pakistan Railways does not publish fares in the public timetable).
  final double? price;

  const Journey({
    required this.from,
    required this.to,
    required this.train,
    required this.departureTime,
    required this.arrivalTime,
    this.price,
  });

  @override
  List<Object?> get props => [
    from,
    to,
    train,
    departureTime,
    arrivalTime,
    price,
  ];
}
