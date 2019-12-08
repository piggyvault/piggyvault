import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => null;
}

class LoadUserSettings extends SettingsEvent {}

class ChangeDefaultCurrency extends SettingsEvent {
  final String currencyCode;

  ChangeDefaultCurrency({@required this.currencyCode})
      : assert(currencyCode != null);

  @override
  List<Object> get props => [currencyCode];
}
