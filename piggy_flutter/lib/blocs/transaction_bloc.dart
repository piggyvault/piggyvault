import 'dart:async';
import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/recent_transactions_state.dart';
import 'package:piggy_flutter/models/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/models/transaction_group_item.dart';

class TransactionBloc implements BlocBase {
  final TransactionService _transactionService = TransactionService();

  final _syncSubject = PublishSubject<bool>();

  final _transactionsGroupBy =
      BehaviorSubject<TransactionsGroupBy>(seedValue: TransactionsGroupBy.Date);
  final _transactionSummary = BehaviorSubject<TransactionSummary>();
  final _recentTransactionsState = BehaviorSubject<RecentTransactionsState>();

  Stream<bool> get syncStream => _syncSubject.stream;

  Stream<TransactionsGroupBy> get transactionsGroupBy =>
      _transactionsGroupBy.stream;

  Stream<TransactionSummary> get transactionSummary =>
      _transactionSummary.stream;
  Stream<RecentTransactionsState> get recentTransactionsState =>
      _recentTransactionsState.stream;

  Function(TransactionsGroupBy) get changeTransactionsGroupBy =>
      _transactionsGroupBy.sink.add;

  Function(bool) get sync => _syncSubject.sink.add;

  TransactionBloc() {
//    print("########## TransactionBloc");
    _syncSubject.stream.listen(_handleSync);
    _transactionsGroupBy.stream.listen(onTransactionsGroupByChanged);
  }

  void onTransactionsGroupByChanged(TransactionsGroupBy groupBy) async {
    print(
        '########## TransactionBloc onTransactionsGroupByChanged groupBy $groupBy');
    await getRecentTransactions();
  }

  Future<Null> getRecentTransactions() async {
    print(
        "########## TransactionBloc getRecentTransactions ${_recentTransactionsState.value}");
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
      } else {
        _recentTransactionsState.add(RecentTransactionsPopulated(result));
      }
    } catch (e) {
      _recentTransactionsState.add(RecentTransactionsError());
    }
  }

  Future<Null> getTransactionSummary() async {
//    print("########## TransactionBloc getTransactionSummary");
    var result = await _transactionService.getTransactionSummary('month');
    _transactionSummary.add(result);
  }

  void dispose() {
    _transactionSummary.close();
    _syncSubject.close();
    _recentTransactionsState.close();
    _transactionsGroupBy.close();
  }

  void _handleSync(bool event) async {
    await getRecentTransactions();
    await getTransactionSummary();
  }
}
