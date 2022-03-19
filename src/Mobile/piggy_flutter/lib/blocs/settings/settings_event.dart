abstract class SettingsEvent {
  const SettingsEvent();
}

class LoadUserSettings extends SettingsEvent {}

class ChangeDefaultCurrency extends SettingsEvent {
  final String currencyCode;

  ChangeDefaultCurrency({required this.currencyCode})
      : assert(currencyCode != null);

  @override
  List<Object> get props => [currencyCode];
}
