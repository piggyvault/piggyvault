import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class TransactionSummaryState extends Equatable {
  const TransactionSummaryState();

  @override
  List<Object> get props => ([]);
}

class TransactionSummaryEmpty extends TransactionSummaryState {}

class TransactionSummaryLoading extends TransactionSummaryState {}

class TransactionSummaryLoaded extends TransactionSummaryState {
  final TransactionSummary summary;

  const TransactionSummaryLoaded({@required this.summary})
      : assert(summary != null);
  @override
  List<Object> get props => ([summary]);
}

class TransactionSummaryError extends TransactionSummaryState {}
