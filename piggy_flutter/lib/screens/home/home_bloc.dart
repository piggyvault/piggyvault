import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
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

  HomeBloc() {
    _syncDataSubject.stream.listen(_handleDataSync);
  }

  _handleTransactionSummaryRefresh() async {
    var result = await _transactionService.getTransactionSummary('month');
    _transactionSummarySubject.add(result);
  }

  _handleDataSync(bool event) async {
    await _handleTransactionSummaryRefresh();
  }

  void dispose() {
    _transactionSummarySubject?.close();
    _syncDataSubject?.close();
  }
}
