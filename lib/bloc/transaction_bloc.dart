import 'dart:async';
import 'package:piggy_flutter/model/transaction_comment.dart';
import 'package:piggy_flutter/model/transaction_edit_dto.dart';
import 'package:piggy_flutter/model/transaction_summary.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:piggy_flutter/model/transaction_group_item.dart';

class TransactionBloc {
  final TransactionService _transactionService = TransactionService();

  final _comment = BehaviorSubject<String>();
  final _isRecentTransactionsLoadingSubject =
      BehaviorSubject<bool>(seedValue: false);
  final _recentTransactionsRefresh = PublishSubject<bool>();
  final _transactionSummaryRefresh = PublishSubject<String>();
  final _transactionCommentsRefresh = PublishSubject<String>();
  final _isTransactionSyncRequired = PublishSubject<bool>();
  final _transactionComments = PublishSubject<List<TransactionComment>>();
  final _transactionsGroupBy =
      BehaviorSubject<TransactionsGroupBy>(seedValue: TransactionsGroupBy.Date);
  final _transactionSummary = BehaviorSubject<TransactionSummary>();
  final _recentTransactions = BehaviorSubject<List<TransactionGroupItem>>();
  final _saveTransactionController = StreamController<TransactionEditDto>();
  final _transferController = StreamController<TransferInput>();

  Stream<String> get comment => _comment.stream.transform(validateComment);
  Stream<bool> get isRecentTransactionsLoading =>
      _isRecentTransactionsLoadingSubject.stream;
  Stream<TransactionsGroupBy> get transactionsGroupBy =>
      _transactionsGroupBy.stream;
  Stream<List<TransactionComment>> get transactionComments =>
      _transactionComments.stream;
  Stream<TransactionSummary> get transactionSummary =>
      _transactionSummary.stream;
  Stream<List<TransactionGroupItem>> get recentTransactions =>
      _recentTransactions.stream;
  Stream<bool> get isTransactionSyncRequired =>
      _isTransactionSyncRequired.stream;

  Function(String) get changeComment => _comment.sink.add;
  Function(TransactionsGroupBy) get changeTransactionsGroupBy =>
      _transactionsGroupBy.sink.add;

  Function(bool) get recentTransactionsRefresh =>
      _recentTransactionsRefresh.sink.add;
  Function(String) get transactionSummaryRefresh =>
      _transactionSummaryRefresh.sink.add;

  Function(String) get transactionCommentsRefresh =>
      _transactionCommentsRefresh.sink.add;

  Function(TransactionEditDto) get saveTransaction =>
      _saveTransactionController.sink.add;

  Function(TransferInput) get doTransfer => _transferController.sink.add;

  TransactionBloc() {
//    print("########## TransactionBloc");
    _saveTransactionController.stream.listen(createOrUpdateTransaction);
    _recentTransactionsRefresh.stream.listen(getRecentTransactions);
    _transactionSummaryRefresh.stream.listen(getTransactionSummary);
    _transferController.stream.listen(transfer);
    _transactionCommentsRefresh.stream.listen(getTransactionComments);
    _transactionsGroupBy.stream.listen(onTransactionsGroupByChanged);
  }

  submitComment(String transactionId) async {
    // print("########## TransactionBloc submitComment");
    final validComment = _comment.value;
    await _transactionService.saveTransactionComment(
        transactionId, validComment);
    transactionCommentsRefresh(transactionId);
    changeComment('');
  }

  void onTransactionsGroupByChanged(TransactionsGroupBy groupBy) {
    recentTransactionsRefresh(true);
  }

  Future<Null> getTransactionComments(String id) async {
    // print("########## TransactionBloc getTransactionComments");
    var result = await _transactionService.getTransactionComments(id);
    _transactionComments.add(result);
  }

  Future<Null> getRecentTransactions(bool done) async {
//    print("########## TransactionBloc getRecentTransactions");
    _isRecentTransactionsLoadingSubject.add(true);
    var result = await _transactionService.getTransactions(GetTransactionsInput(
        type: 'tenant',
        accountId: null,
        startDate: DateTime.now().add(Duration(days: -30)),
        endDate: DateTime.now().add(Duration(days: 1)),
        groupBy: _transactionsGroupBy.value));
    _recentTransactions.add(result.items);
    _isRecentTransactionsLoadingSubject.add(false);
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
    _isTransactionSyncRequired.sink.add(true);
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
    _saveTransactionController.close();
    _recentTransactionsRefresh.close();
    _transferController.close();
    _transactionComments.close();
    _transactionCommentsRefresh.close();
    _comment.close();
    _transactionsGroupBy.close();
    _isRecentTransactionsLoadingSubject.close();
    _isTransactionSyncRequired.close();
  }
}
