import 'dart:async';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final TransactionService _transactionService = new TransactionService();

  final recentTransactionsController = StreamController<bool>();

  final transactionController = StreamController<GetTransactionsInput>();
  final transactionSummaryController = StreamController<String>();
  final saveTransactionController = StreamController<SaveTransactionInput>();

  final recentTransactionsResultController =
      BehaviorSubject<List<TransactionGroupItem>>();
  final transactionSummaryResultController =
      BehaviorSubject<TransactionSummary>();

  Stream<TransactionSummary> get transactionSummary =>
      transactionSummaryResultController.stream;

  Stream<List<TransactionGroupItem>> get recentTransactions =>
      recentTransactionsResultController.stream;

  Sink<bool> get refreshRecentTransactionsSink =>
      recentTransactionsController.sink;

  Sink<String> get transactionSummarySink => transactionSummaryController.sink;

  Sink<SaveTransactionInput> get saveTransaction =>
      saveTransactionController.sink;

  TransactionBloc() {
    print("########## TransactionBloc");
    saveTransactionController.stream.listen(createOrUpdateTransaction);
    recentTransactionsController.stream.listen(getRecentTransactions);
    transactionSummaryController.stream.listen(getTransactionSummary);
  }

  void getRecentTransactions(bool done) async {
    print("########## TransactionBloc getRecentTransactions");
    await _transactionService.getTransactions(GetTransactionsInput(
        'tenant',
        null,
        new DateTime.now().add(new Duration(days: -30)).toString(),
        new DateTime.now().add(new Duration(days: 1)).toString(),
        'recent'));
    recentTransactionsResultController
        .add(_transactionService.recentTransactions);
  }

  void getTransactionSummary(String duration) async {
    print("########## TransactionBloc getTransactionSummary");
    await _transactionService.getTransactionSummary(duration);
    transactionSummaryResultController
        .add(_transactionService.transactionSummary);
  }

  void createOrUpdateTransaction(SaveTransactionInput input) async {
    print("########## TransactionBloc createOrUpdateTransaction");
    var result = await _transactionService.createOrUpdateTransaction(input);
    input.accountBloc.accountsRefresh.add(true);
//        .then((result) =>
//        refreshRecentTransactionsSink.add(true)
//    );
  }

  void dispose() {
    transactionController.close();
    recentTransactionsResultController.close();
    transactionSummaryController.close();
    transactionSummaryResultController.close();
    saveTransactionController.close();
    recentTransactionsController.close();
  }
}
