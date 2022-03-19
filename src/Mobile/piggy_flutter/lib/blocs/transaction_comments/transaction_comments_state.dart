import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class TransactionCommentsState extends Equatable {
  const TransactionCommentsState();
}

class TransactionCommentsLoading extends TransactionCommentsState {
  @override
  List<Object> get props => [];
}

class TransactionCommentsLoaded extends TransactionCommentsState {
  final List<TransactionComment> comments;

  TransactionCommentsLoaded({required this.comments});

  @override
  List<Object> get props => [comments];
}

class TransactionCommentsError extends TransactionCommentsState {
  final String errorMessage;

  TransactionCommentsError({required this.errorMessage});

  @override
  String toString() => 'TransactionCommentsError { error: $errorMessage }';

  @override
  List<Object> get props => [errorMessage];
}
