import 'dart:async';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final transactionController = StreamController<GetTransactionsInput>();
  final transactionSummaryController = StreamController<String>();
  final TransactionService _transactionService = new TransactionService();

  final recentTransactionsResultController =
      BehaviorSubject<List<TransactionGroupItem>>();
  final transactionSummaryResultController =
      BehaviorSubject<TransactionSummary>();

  Stream<TransactionSummary> get transactionSummary =>
      transactionSummaryResultController.stream;

  Stream<List<TransactionGroupItem>> get recentTransactions =>
      recentTransactionsResultController.stream;

  Sink<GetTransactionsInput> get recentTransactionSink =>
      transactionController.sink;

  Sink<String> get transactionSummarySink => transactionSummaryController.sink;

  TransactionBloc() {
    transactionController.stream.listen(getRecentTransactions);
    transactionSummaryController.stream.listen(getTransactionSummary);
  }

  void getRecentTransactions(GetTransactionsInput getTransactionInput) async {
    await _transactionService.getTransactions(getTransactionInput);
    recentTransactionsResultController
        .add(_transactionService.recentTransactions);
  }

  void getTransactionSummary(String duration) async {
    await _transactionService.getTransactionSummary(duration);
    transactionSummaryResultController
        .add(_transactionService.transactionSummary);
  }

  void dispose() {
    transactionController.close();
    recentTransactionsResultController.close();
    transactionSummaryController.close();
    transactionSummaryResultController.close();
  }
}
