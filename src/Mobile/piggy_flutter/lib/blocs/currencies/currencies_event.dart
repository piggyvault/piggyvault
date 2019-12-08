import 'package:equatable/equatable.dart';

abstract class CurrenciesEvent extends Equatable {
  const CurrenciesEvent();
  @override
  List<Object> get props => [];
}

class LoadCurrencies extends CurrenciesEvent {}
