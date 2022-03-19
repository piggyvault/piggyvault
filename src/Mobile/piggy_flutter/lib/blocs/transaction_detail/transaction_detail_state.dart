abstract class TransactionDetailState {
  const TransactionDetailState();
}

class InitialTransactionDetailState extends TransactionDetailState {
  @override
  List<Object> get props => [];
}

class TransactionDeleting extends TransactionDetailState {}

class TransactionDeleted extends TransactionDetailState {}

class TransactionDetailError extends TransactionDetailState {
  final String errorMessage;

  TransactionDetailError({required this.errorMessage});

  @override
  String toString() => 'TransactionDetailError { error: $errorMessage }';

  @override
  List<Object> get props => [errorMessage];
}
