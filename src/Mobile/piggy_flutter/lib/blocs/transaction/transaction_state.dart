import 'package:equatable/equatable.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
}

class InitialTransactionsState extends TransactionState {
  @override
  List<Object> get props => [];
}

class SavingTransaction extends TransactionState {
  @override
  List<Object> get props => [];
}

class TransactionSaved extends TransactionState {
  @override
  List<Object> get props => [];
}

class SaveTransactionError extends TransactionState {
  @override
  List<Object> get props => [];
}
