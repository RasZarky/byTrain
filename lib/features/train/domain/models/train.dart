import 'package:equatable/equatable.dart';

class Train extends Equatable {
  final String id;
  final String name;
  final String number;
  final String status;
  final String departureTime;
  final String arrivalTime;

  const Train({
    required this.id,
    required this.name,
    required this.number,
    required this.status,
    required this.departureTime,
    required this.arrivalTime,
  });

  @override
  List<Object?> get props => [id, name, number, status, departureTime, arrivalTime];
}
