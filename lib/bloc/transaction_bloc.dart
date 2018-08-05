import 'dart:async';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final TransactionService _transactionService = new TransactionService();
  List<TransactionGroupItem> _recentTransactionItems;
  TransactionSummary _transactionSummaryItem;

  final recentTransactionsRefreshController = StreamController<bool>();

  Sink<bool> get recentTransactionsRefresh =>
      recentTransactionsRefreshController.sink;

  final _transactionSummary = BehaviorSubject<TransactionSummary>();

  Stream<TransactionSummary> get transactionSummary =>
      _transactionSummary.stream;

  final _recentTransactions = BehaviorSubject<List<TransactionGroupItem>>();

  Stream<List<TransactionGroupItem>> get recentTransactions =>
      _recentTransactions.stream;

  final transactionSummaryRefreshController = StreamController<String>();

  Sink<String> get transactionSummaryRefresh =>
      transactionSummaryRefreshController.sink;

  final saveTransactionController = StreamController<TransactionEditDto>();

  Sink<TransactionEditDto> get saveTransaction =>
      saveTransactionController.sink;

  final transferController = StreamController<TransferInput>();

  Sink<TransferInput> get doTransfer => transferController.sink;

  TransactionBloc() {
//    print("########## TransactionBloc");
    getRecentTransactions(true);
    getTransactionSummary('month');
    saveTransactionController.stream.listen(createOrUpdateTransaction);
    recentTransactionsRefreshController.stream.listen(getRecentTransactions);
    transactionSummaryRefreshController.stream.listen(getTransactionSummary);
    transferController.stream.listen(transfer);
  }

  Future<Null> getRecentTransactions(bool done) async {
//    print("########## TransactionBloc getRecentTransactions");
    var result = await _transactionService.getTransactions(GetTransactionsInput(
        'tenant',
        null,
        new DateTime.now().add(new Duration(days: -30)).toString(),
        new DateTime.now().add(new Duration(days: 1)).toString(),
        'recent'));
    _recentTransactionItems = result;
    _recentTransactions.add(_recentTransactionItems);
  }

  void getTransactionSummary(String duration) async {
//    print("########## TransactionBloc getTransactionSummary");
    _transactionSummaryItem =
        await _transactionService.getTransactionSummary(duration);
    _transactionSummary.add(_transactionSummaryItem);
  }

  void createOrUpdateTransaction(TransactionEditDto input) async {
//    print("########## TransactionBloc createOrUpdateTransaction");
    await _transactionService.createOrUpdateTransaction(input);
    input.accountBloc.accountsRefresh.add(true);
    recentTransactionsRefresh.add(true);
    transactionSummaryRefresh.add("month");
  }

  void transfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    await _transactionService.transfer(input);
    input.accountBloc.accountsRefresh.add(true);
    recentTransactionsRefresh.add(true);
    transactionSummaryRefresh.add("month");
  }

  void dispose() {
    _transactionSummary.close();
    transactionSummaryRefreshController.close();
    _recentTransactions.close();
    saveTransactionController.close();
    recentTransactionsRefreshController.close();
    transferController.close();
  }
}
