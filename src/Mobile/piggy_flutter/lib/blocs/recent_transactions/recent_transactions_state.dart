import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';

abstract class RecentTransactionsState extends Equatable {
  const RecentTransactionsState();
  @override
  List<Object> get props => [];
}

class RecentTransactionsEmpty extends RecentTransactionsState {}

class RecentTransactionsLoading extends RecentTransactionsState {}

class RecentTransactionsLoaded extends RecentTransactionsState {
  final TransactionsResult result;
  final String latestTransactionDate;

  RecentTransactionsLoaded(
      {@required this.result, @required this.latestTransactionDate});
}

class RecentTransactionsError extends RecentTransactionsState {}
