import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();
}

class DeleteTransaction extends TransactionDetailEvent {
  final String transactionId;

  DeleteTransaction({required this.transactionId})
      : assert(transactionId != null);

  @override
  List<Object> get props => [transactionId];
}
