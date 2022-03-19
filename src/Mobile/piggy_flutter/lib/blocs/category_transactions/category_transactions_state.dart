import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

// TODO(abhith): need to re-visit filters handling in states
abstract class CategoryTransactionsState extends Equatable {
  final GetTransactionsInput? filters;

  const CategoryTransactionsState(this.filters);
  @override
  List<Object?> get props => [];
}

class CategoryTransactionsEmpty extends CategoryTransactionsState {
  CategoryTransactionsEmpty(GetTransactionsInput? filters) : super(filters);
}

class CategoryTransactionsLoading extends CategoryTransactionsState {
  CategoryTransactionsLoading(GetTransactionsInput filters) : super(filters);
}

class CategoryTransactionsLoaded extends CategoryTransactionsState {
  final TransactionsResult allCategoryTransactions;
  final TransactionsResult filterdCategoryTransactions;
  final GetTransactionsInput? filters;

  CategoryTransactionsLoaded(
      {required this.allCategoryTransactions,
      required this.filterdCategoryTransactions,
      required this.filters})
      : super(filters);

  @override
  List<Object?> get props =>
      [allCategoryTransactions, filterdCategoryTransactions, filters];
}

class CategoryTransactionsError extends CategoryTransactionsState {
  CategoryTransactionsError(GetTransactionsInput filters) : super(filters);
}
