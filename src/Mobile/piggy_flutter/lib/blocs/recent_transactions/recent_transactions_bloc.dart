import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/repositories.dart';
import './bloc.dart';

class RecentTransactionsBloc
    extends Bloc<RecentTransactionsEvent, RecentTransactionsState> {
  final TransactionRepository transactionRepository;

  RecentTransactionsBloc({@required this.transactionRepository})
      : assert(transactionRepository != null);

  @override
  RecentTransactionsState get initialState => RecentTransactionsEmpty();

  @override
  Stream<RecentTransactionsState> mapEventToState(
    RecentTransactionsEvent event,
  ) async* {
    if (event is LoadRecentTransactions) {
      yield RecentTransactionsLoading();
      try {
        final result = await transactionRepository.getTransactions(
            GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: TransactionsGroupBy.Date));

        if (result.isEmpty) {
          yield RecentTransactionsEmpty();
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              result: result,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime)));
        }
      } catch (e) {
        RecentTransactionsError();
      }
    }

    if (event is GroupRecentTransactions) {
      yield RecentTransactionsLoading();
      try {
        final result = await transactionRepository.getTransactions(
            GetTransactionsInput(
                type: 'tenant',
                accountId: null,
                startDate: DateTime.now().add(Duration(days: -30)),
                endDate: DateTime.now().add(Duration(days: 1)),
                groupBy: event.groupBy));

        if (result.isEmpty) {
          yield RecentTransactionsEmpty();
        } else {
          final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");

          yield RecentTransactionsLoaded(
              result: result,
              latestTransactionDate: formatter.format(
                  DateTime.parse(result.transactions[0].transactionTime)));
        }
      } catch (e) {
        RecentTransactionsError();
      }
    }
  }
}
