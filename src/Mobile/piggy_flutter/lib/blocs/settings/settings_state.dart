import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;

  SettingsLoaded({required this.settings}) : assert(settings != null);

  @override
  List<Object> get props => [settings];
}

class SettingsError extends SettingsState {
  final String errorMessage;

  SettingsError({required this.errorMessage});

  @override
  String toString() => 'SettingsError { error: $errorMessage }';

  @override
  List<Object> get props => [errorMessage];
}
