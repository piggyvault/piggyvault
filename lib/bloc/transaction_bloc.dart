import 'dart:async';
import 'package:piggy_flutter/viewmodel/recent_transactions_view_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final transactionController = StreamController<RecentTransactionsViewModel>();

  final recentTransactionsResultController =
      BehaviorSubject<List<TransactionGroupItem>>();

  Stream<List<TransactionGroupItem>> get recentTransactions => recentTransactionsResultController.stream;

  Sink<RecentTransactionsViewModel> get recentTransactionSink =>
      transactionController.sink;

  TransactionBloc() {
    transactionController.stream.listen(getRecentTransactions);
  }

  void getRecentTransactions(RecentTransactionsViewModel model) async {
    await model.transactionService.getTransactions(model.getTransactionInput);
    recentTransactionsResultController
        .add(model.transactionService.recentTransactions);
  }

  void dispose() {
    transactionController.close();
    recentTransactionsResultController.close();
  }
}
