import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class AccountTransactionsBloc
    extends Bloc<AccountTransactionsEvent, AccountTransactionsState> {
  final TransactionRepository transactionRepository;

  final TransactionBloc transactionBloc;
  StreamSubscription transactionBlocSubscription;

  AccountTransactionsBloc(
      {@required this.transactionRepository, @required this.transactionBloc})
      : assert(transactionRepository != null),
        assert(transactionBloc != null) {
    transactionBlocSubscription = transactionBloc.listen((state) {
      if (state is TransactionSaved) {
        if (this.state.filters != null) {
          add(FetchAccountTransactions(input: this.state.filters));
        }
      }
    });
  }

  @override
  AccountTransactionsState get initialState => AccountTransactionsEmpty(null);

  @override
  Stream<AccountTransactionsState> mapEventToState(
    AccountTransactionsEvent event,
  ) async* {
    if (event is FetchAccountTransactions) {
      yield AccountTransactionsLoading(event.input);

      try {
        final result = await transactionRepository.getTransactions(event.input);
        if (result.isEmpty) {
          yield AccountTransactionsEmpty(event.input);
        } else {
          yield AccountTransactionsLoaded(result: result, filters: event.input);
        }
      } catch (e) {
        yield AccountTransactionsError(event.input);
      }
    }
  }

  @override
  Future<void> close() {
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
