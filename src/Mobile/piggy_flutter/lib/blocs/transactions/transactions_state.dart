import 'package:equatable/equatable.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();
}

class InitialTransactionsState extends TransactionsState {
  @override
  List<Object> get props => [];
}

class SavingTransaction extends TransactionsState {
  @override
  List<Object> get props => [];
}

class TransactionSaved extends TransactionsState {
  @override
  List<Object> get props => [];
}

class SaveTransactionError extends TransactionsState {
  @override
  List<Object> get props => [];
}
