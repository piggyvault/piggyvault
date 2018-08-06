import 'dart:async';
import 'package:piggy_flutter/model/transaction_comment.dart';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final TransactionService _transactionService = new TransactionService();

  final _recentTransactionsRefresh = PublishSubject<bool>();
  final _transactionSummaryRefresh = PublishSubject<String>();
  final _transactionCommentsRefresh = PublishSubject<String>();
  final _transactionComments = PublishSubject<List<TransactionComment>>();
  final _comment = BehaviorSubject<String>();

  Stream<String> get comment => _comment.stream.transform(validateComment);

  Function(String) get changeComment => _comment.sink.add;
  Function(bool) get recentTransactionsRefresh =>
      _recentTransactionsRefresh.sink.add;
  Function(String) get transactionSummaryRefresh =>
      _transactionSummaryRefresh.sink.add;

  Function(String) get transactionCommentsRefresh =>
      _transactionCommentsRefresh.sink.add;

  final _transactionSummary = BehaviorSubject<TransactionSummary>();

  Stream<List<TransactionComment>> get transactionComments =>
      _transactionComments.stream;

  Stream<TransactionSummary> get transactionSummary =>
      _transactionSummary.stream;

  final _recentTransactions = BehaviorSubject<List<TransactionGroupItem>>();

  Stream<List<TransactionGroupItem>> get recentTransactions =>
      _recentTransactions.stream;

  final saveTransactionController = StreamController<TransactionEditDto>();

  Sink<TransactionEditDto> get saveTransaction =>
      saveTransactionController.sink;

  final transferController = StreamController<TransferInput>();

  Sink<TransferInput> get doTransfer => transferController.sink;

  TransactionBloc() {
//    print("########## TransactionBloc");
    saveTransactionController.stream.listen(createOrUpdateTransaction);
    _recentTransactionsRefresh.stream.listen(getRecentTransactions);
    _transactionSummaryRefresh.stream.listen(getTransactionSummary);
    transferController.stream.listen(transfer);
    _transactionCommentsRefresh.stream.listen(getTransactionComments);
  }

  submitComment(String transactionId) async {
    // print("########## TransactionBloc submitComment");
    final validComment = _comment.value;
    await _transactionService.saveTransactionComment(
        transactionId, validComment);
    transactionCommentsRefresh(transactionId);
    changeComment('');
  }

  Future<Null> getTransactionComments(String id) async {
    // print("########## TransactionBloc getTransactionComments");
    var result = await _transactionService.getTransactionComments(id);
    _transactionComments.add(result);
  }

  Future<Null> getRecentTransactions(bool done) async {
//    print("########## TransactionBloc getRecentTransactions");
    var result = await _transactionService.getTransactions(GetTransactionsInput(
        'tenant',
        null,
        new DateTime.now().add(new Duration(days: -30)).toString(),
        new DateTime.now().add(new Duration(days: 1)).toString(),
        'recent'));
    _recentTransactions.add(result);
  }

  void getTransactionSummary(String duration) async {
//    print("########## TransactionBloc getTransactionSummary");
    var result = await _transactionService.getTransactionSummary(duration);
    _transactionSummary.add(result);
  }

  void createOrUpdateTransaction(TransactionEditDto input) async {
//    print("########## TransactionBloc createOrUpdateTransaction");
    await _transactionService.createOrUpdateTransaction(input);
    input.accountBloc.accountsRefresh(true);
    recentTransactionsRefresh(true);
    transactionSummaryRefresh("month");
  }

  void transfer(TransferInput input) async {
//    print("########## TransactionBloc transfer");
    await _transactionService.transfer(input);
    input.accountBloc.accountsRefresh(true);
    recentTransactionsRefresh(true);
    transactionSummaryRefresh("month");
  }

  final validateComment = StreamTransformer<String, String>.fromHandlers(
      handleData: (comment, sink) {
    // TODO
    // if (comment.isEmpty) {
    //   sink.addError('Comment cannot be empty');
    // } else {
    sink.add(comment);
    // }
  });

  void dispose() {
    _transactionSummary.close();
    _transactionSummaryRefresh.close();
    _recentTransactions.close();
    saveTransactionController.close();
    _recentTransactionsRefresh.close();
    transferController.close();
    _transactionComments.close();
    _transactionCommentsRefresh.close();
    _comment.close();
  }
}
