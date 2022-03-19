import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class CurrenciesBloc extends Bloc<CurrenciesEvent, CurrenciesState> {
  // TODO: move to currency repo
  final AccountRepository accountRepository;

  CurrenciesBloc({required this.accountRepository})
      : super(CurrenciesLoading());

  @override
  Stream<CurrenciesState> mapEventToState(
    CurrenciesEvent event,
  ) async* {
    if (event is LoadCurrencies) {
      yield CurrenciesLoading();

      try {
        var currencies = await accountRepository.getCurrencies();
        yield CurrenciesLoaded(currencies: currencies);
      } catch (e) {
        yield CurrenciesError();
      }
    }
  }
}
