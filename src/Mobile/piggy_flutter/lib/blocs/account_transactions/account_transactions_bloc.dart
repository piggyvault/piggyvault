import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:piggy_flutter/blocs/transaction/transaction.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class AccountTransactionsBloc
    extends Bloc<AccountTransactionsEvent, AccountTransactionsState> {
  final TransactionRepository transactionRepository;

  final TransactionBloc transactionBloc;
  late StreamSubscription transactionBlocSubscription;

  AccountTransactionsBloc(
      {required this.transactionRepository, required this.transactionBloc})
      : super(AccountTransactionsEmpty(null)) {
    transactionBlocSubscription = transactionBloc.stream.listen((state) {
      if (state is TransactionSaved) {
        if (this.state.filters != null) {
          add(FetchAccountTransactions(input: this.state.filters!));
        }
      }
    });
  }

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
          yield AccountTransactionsLoaded(
              allAccountTransactions: result,
              filteredAccountTransactions: result,
              filters: event.input);
        }
      } catch (e) {
        yield AccountTransactionsError(event.input);
      }
    } else if (event is FilterAccountTransactions) {
      if (state is AccountTransactionsLoaded) {
        if (event.query == "") {
          yield AccountTransactionsLoaded(
              allAccountTransactions:
                  (state as AccountTransactionsLoaded).allAccountTransactions,
              filteredAccountTransactions:
                  (state as AccountTransactionsLoaded).allAccountTransactions,
              filters: state.filters);
        } else {
          var filteredTransactions = (state as AccountTransactionsLoaded)
              .allAccountTransactions
              .transactions
              .where((t) => t.description!
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
              .toList();
          var filteredTransactionsResult = TransactionsResult(
              sections: transactionRepository.groupTransactions(
                  transactions: filteredTransactions,
                  groupBy: TransactionsGroupBy.Date),
              transactions: filteredTransactions);

          yield AccountTransactionsLoaded(
              allAccountTransactions:
                  (state as AccountTransactionsLoaded).allAccountTransactions,
              filteredAccountTransactions: filteredTransactionsResult,
              filters: state.filters);
        }
      }
    }
  }

  @override
  Future<void> close() {
    transactionBlocSubscription.cancel();
    return super.close();
  }
}
