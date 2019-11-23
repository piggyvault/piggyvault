import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
}

class SaveTransaction extends TransactionsEvent {
  final TransactionEditDto transactionEditDto;

  const SaveTransaction({@required this.transactionEditDto})
      : assert(transactionEditDto != null);

  @override
  List<Object> get props => [transactionEditDto];
}

class DoTransfer extends TransactionsEvent {
  final TransferInput transferInput;

  const DoTransfer({@required this.transferInput})
      : assert(transferInput != null);

  @override
  List<Object> get props => [transferInput];
}
