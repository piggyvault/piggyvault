import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/models/user_settings.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserRepository userRepository;

  SettingsBloc({required this.userRepository}) : super(SettingsLoading()) {
    add(LoadUserSettings());
  }

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is LoadUserSettings) {
      yield SettingsLoading();

      try {
        var settings = await userRepository.getUserSettings();
        yield SettingsLoaded(settings: settings);
      } catch (error) {
        yield SettingsError(errorMessage: error.toString());
      }
    }

    if (event is ChangeDefaultCurrency) {
      yield SettingsLoading();
      await userRepository.changeDefaultCurrency(event.currencyCode);
      add(LoadUserSettings());
    }
  }
}
