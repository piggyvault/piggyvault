import 'package:equatable/equatable.dart';
import 'package:piggy_flutter/models/currency.dart';

abstract class CurrenciesState extends Equatable {
  const CurrenciesState();

  @override
  List<Object> get props => [];
}

class CurrenciesLoading extends CurrenciesState {}

class CurrenciesLoaded extends CurrenciesState {
  final List<Currency> currencies;

  const CurrenciesLoaded({required this.currencies});
}

class CurrenciesError extends CurrenciesState {}
