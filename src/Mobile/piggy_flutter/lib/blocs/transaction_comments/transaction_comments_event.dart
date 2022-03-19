import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class TransactionCommentsEvent extends Equatable {
  const TransactionCommentsEvent();
}

class PostTransactionComment extends TransactionCommentsEvent {
  final String transactionId;
  final String comment;

  PostTransactionComment({required this.comment, required this.transactionId})
      : assert(transactionId != null),
        assert(comment != null);

  @override
  List<Object> get props => [transactionId, comment];
}

class LoadTransactionComments extends TransactionCommentsEvent {
  final String transactionId;

  LoadTransactionComments({required this.transactionId})
      : assert(transactionId != null);

  @override
  List<Object> get props => [transactionId];
}
