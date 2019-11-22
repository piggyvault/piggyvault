import 'dart:async';

import 'package:intl/intl.dart';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/recent_transactions_state.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';
import 'package:piggy_flutter/models/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc implements BlocBase {
  final TransactionService _transactionService = TransactionService();

  final _transactionSummarySubject = BehaviorSubject<TransactionSummary>();
  Stream<TransactionSummary> get transactionSummary =>
      _transactionSummarySubject.stream;

  final _syncDataSubject = PublishSubject<bool>();
  Stream<bool> get syncDataStream => _syncDataSubject.stream;
  Function(bool) get syncData => _syncDataSubject.sink.add;

  final _transactionsGroupBy =
      BehaviorSubject<TransactionsGroupBy>.seeded(TransactionsGroupBy.Date);
  Stream<TransactionsGroupBy> get transactionsGroupBy =>
      _transactionsGroupBy.stream;
  Function(TransactionsGroupBy) get changeTransactionsGroupBy =>
      _transactionsGroupBy.sink.add;

  final _recentTransactionsState = BehaviorSubject<RecentTransactionsState>();
  Stream<RecentTransactionsState> get recentTransactionsState =>
      _recentTransactionsState.stream;

  final _lastTransactionDateSubject = BehaviorSubject<String>();
  Stream<String> get lastTransactionDate => _lastTransactionDateSubject.stream;

  HomeBloc() {
    _syncDataSubject.stream.listen(_handleDataSync);
    _transactionsGroupBy.stream.listen(onTransactionsGroupByChanged);
  }

  void onTransactionsGroupByChanged(TransactionsGroupBy groupBy) async {
    // print(
    // '########## TransactionBloc onTransactionsGroupByChanged groupBy $groupBy');
    await getRecentTransactions();
  }

  _handleDataSync(bool event) async {
    // await _handleTransactionSummaryRefresh();
    await getRecentTransactions();
  }

  Future<Null> getRecentTransactions() async {
    // print(
    //     "########## TransactionBloc getRecentTransactions ${_recentTransactionsState.value}");
    if (_recentTransactionsState.value is! RecentTransactionsPopulated) {
      _recentTransactionsState.add(RecentTransactionsLoading());
    }

    try {
      var result = await _transactionService.getTransactions(
          GetTransactionsInput(
              type: 'tenant',
              accountId: null,
              startDate: DateTime.now().add(Duration(days: -30)),
              endDate: DateTime.now().add(Duration(days: 1)),
              groupBy: _transactionsGroupBy.value));

      if (result.isEmpty) {
        _recentTransactionsState.add(RecentTransactionsEmpty());
        _lastTransactionDateSubject.add('?');
      } else {
        _recentTransactionsState.add(RecentTransactionsPopulated(result));
        final DateFormat formatter = DateFormat("EEE, MMM d, ''yy");
        _lastTransactionDateSubject.add(formatter
            .format(DateTime.parse(result.transactions[0].transactionTime)));
      }
    } catch (e) {
      _recentTransactionsState.add(RecentTransactionsError());
    }
  }

  void dispose() {
    _transactionSummarySubject?.close();
    _syncDataSubject?.close();
    _transactionsGroupBy?.close();
    _recentTransactionsState?.close();
    _lastTransactionDateSubject?.close();
  }
}
