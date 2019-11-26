import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class AccountTransactionsBloc
    extends Bloc<AccountTransactionsEvent, AccountTransactionsState> {
  final TransactionRepository transactionRepository;

  AccountTransactionsBloc({@required this.transactionRepository})
      : assert(transactionRepository != null);
  @override
  AccountTransactionsState get initialState => AccountTransactionsEmpty();

  @override
  Stream<AccountTransactionsState> mapEventToState(
    AccountTransactionsEvent event,
  ) async* {
    if (event is FetchAccountTransactions) {
      yield AccountTransactionsLoading();

      try {
        final result = await transactionRepository.getTransactions(event.input);
        if (result.isEmpty) {
          yield AccountTransactionsEmpty();
        } else {
          yield AccountTransactionsLoaded(result: result);
        }
      } catch (e) {
        yield AccountTransactionsError();
      }
    }
  }
}
