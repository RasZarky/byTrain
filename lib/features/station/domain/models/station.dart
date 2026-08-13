import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final String name;
  final String code;
  final String city;
  final String province;
  final List<String> facilities;

  const Station({
    required this.id,
    required this.name,
    required this.code,
    this.city = '',
    this.province = '',
    this.facilities = const [],
  });

  @override
  List<Object?> get props => [id, name, code, city, province, facilities];
}
