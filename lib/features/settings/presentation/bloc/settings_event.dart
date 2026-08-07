import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsToggled extends SettingsEvent {
  final bool enabled;

  const NotificationsToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
