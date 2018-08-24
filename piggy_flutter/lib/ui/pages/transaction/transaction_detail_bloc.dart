import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/transaction.dart';
import 'package:piggy_flutter/models/transaction_comment.dart';
import 'package:piggy_flutter/services/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class TransactionDetailBloc implements BlocBase {
  final Transaction transaction;

  TransactionDetailBloc(this.transaction) {
    getTransactionComments();
  }
  final TransactionService _transactionService = TransactionService();

  final _comment = BehaviorSubject<String>();
  Function(String) get changeComment => _comment.sink.add;
  Stream<String> get comment => _comment.stream.transform(validateComment);

  final _transactionComments = BehaviorSubject<List<TransactionComment>>();
  Stream<List<TransactionComment>> get transactionComments =>
      _transactionComments.stream;

  submitComment(String transactionId) async {
    // print("########## TransactionBloc submitComment");
    final validComment = _comment.value;
    await _transactionService.saveTransactionComment(
        transactionId, validComment);
    changeComment('');
    await getTransactionComments();
  }

  Future<Null> getTransactionComments() async {
    // print("########## TransactionBloc getTransactionComments");
    var result =
        await _transactionService.getTransactionComments(transaction.id);
    _transactionComments.add(result);
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
    _comment.close();
  }
}
