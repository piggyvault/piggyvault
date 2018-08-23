import 'package:piggy_flutter/models/transactions_result.dart';

class RecentTransactionsState {}

class RecentTransactionsLoading extends RecentTransactionsState {}

class RecentTransactionsEmpty extends RecentTransactionsState {}

class RecentTransactionsPopulated extends RecentTransactionsState {
  final TransactionsResult result;

  RecentTransactionsPopulated(this.result);
}

class RecentTransactionsError extends RecentTransactionsState {}
