import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class RecentTransactionsState extends Equatable {
  final GetTransactionsInput? filters;

  const RecentTransactionsState(this.filters);
  @override
  List<Object?> get props => [filters];
}

class RecentTransactionsEmpty extends RecentTransactionsState {
  RecentTransactionsEmpty(GetTransactionsInput? filters) : super(filters);
}

class RecentTransactionsLoading extends RecentTransactionsState {
  RecentTransactionsLoading(GetTransactionsInput? filters) : super(filters);
}

class RecentTransactionsLoaded extends RecentTransactionsState {
  final TransactionsResult allTransactions;
  final TransactionsResult filteredTransactions;
  final String latestTransactionDate;
  final GetTransactionsInput? filters;

  RecentTransactionsLoaded(
      {required this.allTransactions,
      required this.filteredTransactions,
      required this.latestTransactionDate,
      required this.filters})
      : super(filters);

  @override
  List<Object?> get props => [allTransactions, filteredTransactions, filters];
}

class RecentTransactionsError extends RecentTransactionsState {
  RecentTransactionsError(GetTransactionsInput? filters) : super(filters);
}
