import 'package:piggy_flutter/services/transaction_service.dart';

class RecentTransactionsViewModel {
  final GetTransactionsInput getTransactionInput;
  final TransactionService transactionService;

  RecentTransactionsViewModel(this.getTransactionInput,
      this.transactionService);
}
