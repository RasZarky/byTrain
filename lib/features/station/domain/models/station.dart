import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<String> facilities;

  const Station({
    required this.id,
    required this.name,
    required this.code,
    this.facilities = const [],
  });

  @override
  List<Object?> get props => [id, name, code, facilities];
}
